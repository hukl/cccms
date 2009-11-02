xml.instruct!

xml.feed(:xmlns => "http://www.w3.org/2005/Atom", "xml:base" => @host) do
  xml.title("CCC.de Recent Change")
  xml.link(:href => "http://www.ccc.de/")
  xml.link(:rel => "self", :href => "/rss/updates.xml")
  xml.updated(@items.first.updated_at.xmlschema)
  xml.author do
    xml.name("Chaos Computer Club e.V.")
  end
  xml.id("http://www.ccc.de/")
  
  @items.each do |item|
    xml.entry do
      xml.title(item.title)
      xml.link(
        :href => "http://www.ccc.de/#{item.node.unique_path}",
        :rel => "alternate"
      )
      xml.id(content_url_helper(item.node.unique_path))
      xml.updated(item.updated_at.xmlschema)
      xml.content(:type => "text") do
        xml.div("changed by #{item.user.login}")
      end
    end
    
  end
  
end