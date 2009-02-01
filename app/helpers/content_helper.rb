module ContentHelper
  
  def date_for_page page
    page.published_at.to_s(:db) rescue page.created_at.to_s(:db)
  end
  
  def aggregate? content
    options = {}
    
    begin
      if content =~ /<aggregate([^<>]*)>/
        tag = $~.to_s
        matched_data = $1.scan(/\w+\=\"[a-zA-Z\s\/_\d]*\"/)
        
        matched_data.each do |data|
          splitted_data = data.split("=")
          options[splitted_data[0].to_sym] = splitted_data[1].gsub(/\"/, "")
        end
        
        content.sub(tag, render_collection(options))
      end
      
    rescue
      content
    end
  end
  
  def render_collection options
    render(
      :partial => 'content/article', 
      :collection => Page.aggregate(options)
    )
  end
end
