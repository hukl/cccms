require 'iconv'
require 'nokogiri'
require 'chaos_calendar'
require 'digest/sha1'


class ChaosXml
  attr_reader :xml, :unique_name, :locale, :date, :slug
  
  def initialize options = {}
    options.each_pair do |key,value|
      instance_variable_set "@#{key}", value
      instance_eval("def #{key}; @#{key};end")
    end
  end
end

class ChaosImporter
  include Enumerable
  
  def initialize path
    unless Node.root
      Node.create! :slug => "root"
    end
    
    @directory  = path
    @years      = {}
  end
  
  # Iterates through all xml files within the @directory and yields ChaosXml
  # objects with the parsed attributes. These attributes are the basic data
  # needed for further processing / parsing.
  def each
    directories = Dir.glob("#{@directory}/*/*.xml{,.de,.en}")
    
    directories.each do |path|
      next if path =~ /index\.xml/
      
      chaos_id              = chaos_id_from_path( path )
      options               = {}
      options[:xml]         = Nokogiri::XML( File.new(path).read )
      options[:locale]      = lang_from_path( path )
      options[:date]        = options[:xml].at("//date").content.to_date
      options[:slug]        = chaos_id
      options[:unique_name] = "updates/#{options[:date].year}/#{options[:slug]}"
      xml                   = ChaosXml.new options
      
      yield xml
    end
  end
  
  def update_authors_on_pages
    self.each do |update|
      author = find_or_create_author( update )
      node = Node.find_by_unique_name( update.unique_name ) || raise("no node")
      pages = node.pages.all(:conditions => {:user_id => nil})
      
      pages.each do |page|
        if page.revision == 1
          page.user = author
          page.save
        end
      end
      
      puts "#{author.try(:login)} >>> #{node.unique_name}"
    end
  end
  
  # Uses the each method to loop over the xml files and uses the attrubutes of 
  # the returned ChaosXml objects to do some further processing which is needed
  # to create proper ActiveRecord records 
  def import_updates
    unless @updates = Node.find_by_unique_name('updates')
      @updates = Node.create!( :slug => 'updates' )
      @updates.move_to_child_of Node.root
    end
    
    self.each do |update|
      
      author  = find_or_create_author( update )
      node    = find_or_create_node( update )
      html    = convert_to_html( update.xml )
      page    = fill_draft_with_content(node.draft, html, update.locale)
      
      add_tags_to_page    page, update.xml, "update"
      add_event_to_node   node, update.xml if page.tag_list.include?("event")
      page.user = author
      page.save
      
      puts node.unique_name
    end
    
    puts ">> Publishing Drafts"
    Node.all.each {|node| node.publish_draft!}
    puts ">> Finished"
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
    path.sub(@directory, "").split(/\//).last.split(/\./)[0]
  end
  
  def find_or_create_author update
    login     = update.xml.at("//author").content rescue "webmaster"

    unless author = User.find_by_login(login.downcase)
      author = User.find_by_login("webmaster")
    end
    
    author 
  end
  
  def find_or_create_node update
    year = update.date.year

    
    unique_name_array = update.unique_name.split("/")
    
    unless @years[year] || (@years[year] = Node.find_by_unique_name("updates/#{year}"))
      @years[year] = Node.create :slug => year
      @years[year].move_to_child_of @updates
    end
    
    unless node = Node.find_by_unique_name(update.unique_name)
      node = Node.create :slug => update.slug
      node.move_to_child_of @years[year]
    end
    
    node
  end
  
  def fill_draft_with_content draft, html, lang
    I18n.locale = lang
    
    draft.reload
    
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
      parsed_duration = ChaosCalendar.duration_to_fixnum(duration.content)
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
    chaospage.xpath('//quote').each     {|sub| sub.name   = "em"  }
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