xml.instruct!
xml.feed(:xmlns => "http://www.w3.org/2005/Atom") do
  xml.title("Chaos Computer Club Updates")
  xml.link(:href => "http://www.ccc.de/")
  xml.updated(@items.first.published_at)
  xml.author("Chaos Computer Club e.V.")
  xml.id("http://www.ccc.de/")
  
  @items.each do |item|
    xml.entry do
      xml.title(item.title)
      port = (request.port != 80) ? port = ":#{request.port}" : ""
      xml.link(request.protocol + request.host + port + item.public_link)
      xml.id(request.protocol + request.host + port + item.public_link)
      xml.updated(item.updated_at)
      xml.content(:type => "xhtml") do
        xml.div(item.body, :xmlns => "http://www.w3.org/1999/xhtml")
      end
    end
    
  end
  
end