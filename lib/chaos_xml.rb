require 'iconv'
require 'nokogiri'
require 'lib/chaos_calendar/ical_occurrences'


class ChaosXml
  include Enumerable
  
  def initialize path
    unless Node.root
      Node.create!
    end
    
    @path = path
    @years = {}
  end
  
  def import_updates
    unless @updates = Node.find_by_unique_name('updates')
      @updates = Node.create!( :slug => 'updates' )
      @updates.move_to_child_of Node.root
    end
    
    self.each do |chaospage, chaos_id, lang|
      node = find_or_create_node( chaospage, chaos_id )
      html = convert_to_html( chaospage )
      page = fill_draft_with_content(node.draft, html, lang)
      
      add_tags_to_page    page, chaospage, "update"
      add_event_to_node   node, chaospage if page.tag_list.include?("event")
      page.save
      puts node.unique_name
    end
    
    Node.all.each {|node| node.publish_draft!}
  end
  
  def each
    directories = Dir.glob("#{@path}/*/*.xml{,.de,.en}")
    
    directories.each do |path|
      next if path =~ /index\.xml/
      chaospage = Nokogiri::XML( File.new(path).read )
      lang      = lang_from_path( path )
      chaos_id  = chaos_id_from_path( path )
      
      yield chaospage, chaos_id, lang  
    end
  end
  
  def lang_from_path path
    case path
    when /\.de$/ then :de
    when /\.en$/ then :en
    else 
      :de
    end
  end
  
  def chaos_id_from_path path
    path.sub(@path, "").split(/\//).last.split(/\./)[0]
  end
  
  def find_or_create_node chaospage, chaos_id
      
    date = chaospage.xpath("//date").first.content.to_date
    unique_name = "updates/#{date.year}/#{chaos_id}"
    year = date.year
    
    unique_name_array = unique_name.split("/")
    
    unless @years[year] || (@years[year] = Node.find_by_unique_name("updates/#{year}"))
      @years[year] = Node.create :slug => year
      @years[year].move_to_child_of @updates
    end
    
    unless node = Node.find_by_unique_name(unique_name)
      node = Node.create :slug => chaos_id
      node.move_to_child_of @years[year]
    end
    
    node
  end
  
  def fill_draft_with_content draft, html, lang
    I18n.locale = lang
    
    options = {
      :title    => html.xpath("//title")[0].content,
      :abstract => html.xpath("//abstract")[0].content,
      :body     => extract_body(html)
    }
    
    draft.update_attributes options
    draft
  end
  
  def extract_body html, excluded_tags=[]
    default_excluded_tags = [
      "DTSTART",
      "DTEND",
      "DURATION",
      "LOCATION",
      "GEO",
      "SUMMARY",
      "URL"
    ]
    
    excluded_tags = (default_excluded_tags + excluded_tags).uniq
    
    body = ""
    element = html.xpath("//abstract")[0].next_sibling
    
    while element do
      body << element.to_s unless excluded_tags.include? element.name
      element = element.next_sibling
    end

    body
  end
  
  def add_tags_to_page page, chaospage, *custom_tags
    tag_list = custom_tags
    
    chaospage.xpath("//flags").each do |node|
      node.each do |k,v|
        case k
        when "calendar"
          tag_list << "event"
        when "pm"
          tag_list << "pressemitteilung"
        end
      end
    end
    
    # Getting rid of duplicate flags
    tag_list.uniq!
    
    page.tag_list = tag_list.join(",")
    page.save    
  end
  
  def add_event_to_node node, chaospage
    rrule     = get_rrule(chaospage)
    
    event_options = {
      :start_time   => get_start_time(chaospage),
      :end_time     => get_end_time(chaospage),
      :allday       => is_allday?(chaospage),
      :rrule        => rrule,
      :custom_rrule => is_custom_rrule?(rrule),
      :location     => get_location(chaospage),
      :url          => get_url(chaospage),
      :latitude     => get_latitude(chaospage),
      :longitude    => get_logitude(chaospage)
    }
    
    unless tmp_event = node.event
      tmp_event = Event.create! event_options.merge({:node_id => node.id})
    else
      tmp_event.update_attributes event_options
    end
  end
  
  def get_start_time chaospage
    chaospage.at("//ical:DTSTART").content || raise("DTSTART not found")
  end
  
  def get_end_time chaospage
    dtstart   = chaospage.at("//ical:DTSTART")
    dtend     = chaospage.at("//ical:DTEND")
    duration  = chaospage.at("//ical:DURATION")
    
    if dtend
      return dtend.content
    elsif duration
      parsed_duration = Ical_occurrences.duration_to_fixnum(duration.content)
      return (dtstart.content.to_time + parsed_duration)
    else
      raise("Neiter DTEND nor DURATION found")
    end
  end

  def is_allday? chaospage
    !chaospage.at("//ical:DTSTART").[]("VALUE").nil?
  end
  
  def get_rrule chaospage
    if rrule = chaospage.at("//ical:RRULE")
      rrtxt = ''
      rrule.children.each do |subrule|
        rule_name    = subrule.name
        rule_content = subrule.content.sub(/\W/,'')
        
        next if rule_content.blank?
        
        rrtxt += "#{rule_name}=#{rule_content};"
      end
      rrtxt.chomp!(';')
      rrtxt
    else
      nil
    end
  end
  
  def is_custom_rrule? rrule
    default_rules = [
      "FREQ=WEEKLY;INTERVAL=1", 
      "FREQ=MONTHLY;INTERVAL=1", 
      "FREQ=YEARLY;INTERVAL=1"
    ]
    
    rrule && !default_rules.include?(rrule) ? true : false
  end
  
  def get_location chaospage
    location = chaospage.at("//ical:LOCATION")
    location ? location.content : nil
  end
  
  def get_url chaospage
    location = chaospage.at("//ical:LOCATION")
    location.[]("ALTREP") if location
  end
  
  def get_latitude chaospage
    geo = chaospage.at("//ical:GEO")
    geo.text.split(";")[0] if geo
  end
  
  def get_logitude chaospage
    geo = chaospage.at("//ical:GEO")
    geo.text.split(";")[1] if geo
  end
  
  def convert_to_html chaospage
    
    chaospage.xpath('//paragraph').each {|sub| sub.name   = "p"}
    chaospage.xpath('//quote').each     {|sub| sub.name   = "blockquote"  }
    chaospage.xpath('//subtitle').each  {|sub| sub.name   = "h3" }
    chaospage.xpath('//strong').each    {|sub| sub.name   = "em" }
    chaospage.xpath('//stronger').each  {|sub| sub.name   = "strong" }
    chaospage.xpath('//chapter').each   {|sub| sub.name   = "h2" }

    chaospage.xpath('//link').each do |sub|
      sub.name = "a"
      href = sub.[]("ref")
      sub.remove_attribute("ref")
      sub.[]=("href", href)
      sub.remove_attribute("type")
    end
    
    chaospage.xpath('//list').each do |sub|
      if !sub.css("row item").empty?
        sub.name = "table"
        
        sub.css("row").each {|x| x.name = "tr"}
        sub.css("tr item").each {|x| x.name = "td"}
      elsif !sub.css("item").empty?
        sub.name = "ul"
        
        sub.css("item").each {|x| x.name = "li"}
      end
    end
    
    chaospage.xpath('//media').each do |sub|
      sub.name = "img"
      src = sub.[]("ref")
      sub.remove_attribute("src")
      sub.[]=("src", src)
      unless sub.content
        sub.[]=("alt", sub.content)
        sub.xpath('//*').each {|x| x.remove}
      end
    end
    
    chaospage.xpath('//name').each do |sub|
      if sub.[]("email")
        mail_href = "mailto:#{sub.[]('email')}"
        sub.remove_attribute("email")
        sub.[]=("href", mail_href)
      end
      sub.name = "a"
      
      if href = sub.[]("ref")
        sub.remove_attribute("ref")
        sub.[]=("href", href)
      end
    end
    
    chaospage
    
  end
end