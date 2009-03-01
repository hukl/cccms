require 'rexml/document'
require 'iconv'

class UpdateImporter
  
  def initialize path
    Node.delete_all
    Page.delete_all
    
    @path = path
    
    unless Node.root
      Node.create!
    end
    
    unless @updates = Node.find_by_unique_name('updates')
      @updates = Node.create!( :slug => 'updates' )
      @updates.move_to_child_of Node.root
    end

  end
  
  # Class Methods
  
  # Instance Methods
  
  def import_xml
    directories = Dir.glob("#{@path}/*/*.xml{,.de,.en}")

    directories.each do |dir|
      next if dir =~ /index\.xml/
      chaospage = REXML::Document.new(File.new(dir))
      
      puts dir
      lang =  case dir
              when /\.de$/ then :de
              when /\.en$/ then :en
              else 
                :de
              end
      
      tmp_dir = dir.sub(@path, "").split(/\//).last
      chaos_id = tmp_dir.split(/\./)[0]
       
      create_node_and_page( chaospage.root, lang, chaos_id )
    end
  end
  
  def create_node_and_page chaospage, lang, chaos_id
    date = chaospage.root.elements['date'].get_text.to_s.to_date
    unique_name = "updates/#{date.year}/#{chaos_id}"
    
    unless parent_node = Node.find_by_unique_name("updates/#{date.year}")
      parent_node = Node.create :slug => date.year
      parent_node.move_to_child_of @updates
    end
    
    
    unless node = Node.find_by_unique_name(unique_name)
      node = Node.create :slug => chaos_id
      node.move_to_child_of parent_node
    end
    
    create_node_for_page chaospage, node, date, lang
  end
  
  def create_node_for_page chaospage, node, date, lang
    
    xhtml = convert_chaospage_to_xhtml(chaospage)
    
    body = ""
    
    element = xhtml.elements['abstract'].next_sibling
    
    while element do
      body << element.to_s
      element = element.next_sibling
    end
    
    if node.pages.empty?
      
      I18n.locale = lang
      
      page = node.pages.create!(
        :title => xhtml.elements['title'].get_text.to_s,
        :abstract => xhtml.elements['abstract'].get_text.to_s,
        :body => body
      )
    else
      page = node.pages.first
      
      I18n.locale = lang
      
      page.update_attributes(
        :title => xhtml.elements['title'].get_text.to_s,
        :abstract => xhtml.elements['abstract'].get_text.to_s,
        :body => body
      )
      
    end
    
    if xhtml.elements['author']
      user = User.find_by_login(xhtml.elements['author'].get_text.to_s)
      page.user = user
    else
      page.user = User.first
    end
    
    page.published_at = date.to_time
    page.save!
    
    puts page.published_at
    
    page.tag_list.add("update") if page
    
    if (flags = xhtml.elements['flags']) && page
      page.tag_list.add("event")            if flags.attributes['calendar']
      page.tag_list.add("pressemitteilung") if flags.attributes['pm']
    end
    
    page.save!
    
    if node.head.nil? && page
      node.head = page
      node.draft = nil
      node.save!
    end
  end
  
  def convert_chaospage_to_xhtml( element )
    element.each_element('//paragraph') {|sub| sub.name = "p"  }
    element.each_element('//link') do    |sub|
      sub.name = "a"
      sub.attributes.get_attribute("ref").name = "href"
      sub.attributes.delete_all("type")
    end
    element.each_element('//quote')     {|sub| sub.name   = "q"  }
    element.each_element('//subtitle')  {|sub| sub.name   = "h3" }
    element.each_element('//strong')    {|sub| sub.name   = "i" }
    element.each_element('//stronger')  {|sub| sub.name   = "b" }
    element.each_element('//chapter')   {|sub| sub.name   = "h2" }

    element.each_element('//list')      {|sub|
      if sub.get_elements( '//row' ).size > 0
        sub.name = "table"
        sub.each_element('//row')       {|row|
          row.name = "tr"
          row.each_element('//item')    {|td|   td.name  = "td"}
        }
      else
        sub.name = "ul"
        sub.each_element('//item)')     {|item| item.name = "li" }
        sub.each_element('//sub')       {|sl|   sl.name   = "ul" }
      end
    }
    element.each_element('//media')     {|sub|
      sub.name = "img"
      sub.attributes.get_attribute("ref").name = "src"
      if sub.has_text?() then
        sub.add_attribute("alt"=>sub.text())
        sub.delete_element('//*')
      end
    }
    element.each_element('//name')      {|sub|
      if sub.attributes.get_attribute("email") then
        sub.attributes["email"] = "mailto:" + sub.attributes["email"]
        sub.attributes.get_attribute("email").name = "href"
      end
      sub.name = "a"
      sub.attributes.get_attribute("ref").name = "href" if sub.attributes.get_attribute("ref")
    }

    element
  end
  
end