xml.instruct!

xml.feed(:xmlns => "http://www.w3.org/2005/Atom", "xml:base" => @host) do
  xml.title("Chaos Computer Club Updates")
  xml.link(:href => "http://www.ccc.de/")
  xml.link(:rel => "self", :href => "/rss/updates.xml")
  xml.updated((@items.first.published_at || @items.first.updated_at).xmlschema)
  xml.author do
    xml.name("Chaos Computer Club e.V.")
  end
  xml.id("http://www.ccc.de/")
  
  @items.each do |item|
    xml.entry do
      xml.title(item.title)
      xml.link(
        :href => content_path_helper(item.node.unique_path),
        :rel => "alternate"
      )
      xml.id(content_url_helper(item.node.unique_path))
      xml.updated(item.updated_at.xmlschema)
      xml.content(:type => "xhtml") do
        xml.div(item.body, :xmlns => "http://www.w3.org/1999/xhtml")
      end
    end
    
  end
  
end