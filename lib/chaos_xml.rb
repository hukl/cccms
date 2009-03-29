require 'iconv'
require 'nokogiri'

class ChaosXml
  include Enumerable
  
  def initialize path
    unless Node.root
      Node.create!
    end
    
    @path = path
    @years = {}
  end
  
  def import_xml
    unless @updates = Node.find_by_unique_name('updates')
      @updates = Node.create!( :slug => 'updates' )
      @updates.move_to_child_of Node.root
    end
    
    self.each do |chaospage, chaos_id, lang|
      node = find_or_create_node( chaospage, chaos_id )
      html = convert_to_html( chaospage )
      page = fill_draft_with_content(node.draft, html, lang)
    end
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
  
  def fill_draft_with_content draft, chaospage, lang
    I18n.locale = lang
    
    options = {
      :title    => chaospage.xpath("//title")[0].content,
      :abstract => chaospage.xpath("//abstract")[0].content,
      :body     => extract_body(chaospage)
    }
    
    puts options.inspect
    #draft.update_attributes options
  end
  
  def extract_body chaospage
    body = ""
    element = chaospage.xpath("//abstract")[0].next_sibling
    
    while element do
      body << element.to_s
      element = element.next_sibling
    end
    
    puts body
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