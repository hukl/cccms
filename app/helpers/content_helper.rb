module ContentHelper
  
  # Returns the published_at attribute of a page if it is not nil, otherwise
  # it returns the auto-filled value of the created_at attribute
  def date_for_page page
    page.published_at.to_s(:db) rescue page.created_at.to_s(:db)
  end
  
  # This method is an output filter for templates. It accepts any kind of text
  # and checks for an <aggregate /> tag within it. If such a tag is found, its 
  # attributes are parsed and converted into parameters for the 
  # render_collection method. The <aggregate /> tag will then be replaced 
  # entirely with the output of the render_collection method.
  #
  # Syntax of the <aggregate /> tag:
  #
  # <aggregate 
  #   flags="update, pressemitteilung"
  #   limit="20"
  #   order_by="published_at"
  #   order_direction="DESC"
  # />
  def aggregate? content
    options = {}
    
    begin
      if content =~ /<aggregate([^<>]*)>/
        tag = $~.to_s
        matched_data = $1.scan(/\w+\=\"[a-zA-Z\s\/_\d,]*\"/)
        
        matched_data.each do |data|
          splitted_data = data.split("=")
          options[splitted_data[0].to_sym] = splitted_data[1].gsub(/\"/, "")
        end
        
        content.sub(tag, render_collection(options))
      else
        content
      end
      
    rescue
      content
    end
  end
  
  # Takes the parameters from the aggregate? method and renders the collection
  # from Page.aggregate(options) with a given partial
  def render_collection options
    render(
      :partial => 'content/article', 
      :collection => Page.aggregate(options)
    )
  end
end
