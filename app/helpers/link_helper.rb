module LinkHelper
  
  def link_to_path title, path
    params[:locale] ||= I18n.locale
    
    link_to( 
      title,
      :controller => :content,
      :action => :render_page,
      :locale => params[:locale],
      :page_path => path
    )
  end
  
  def selected? controller_name
    if params[:controller] == controller_name
      return :class => "selected"
    end
  end
end