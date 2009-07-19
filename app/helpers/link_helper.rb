module LinkHelper
  
  def link_to_path title, path, html_options = {}
    if params[:page_path]
      active = (params[:page_path].join("/") == path.sub(/^\//, ""))
    end
    
    params[:locale] ||= I18n.locale
    
    link_to( 
      title, {
        :controller => :content,
        :action => :render_page,
        :locale => params[:locale],
        :page_path => path.sub(/^\//, "").split("/")
      },
      active ? {:class => 'active'} : {:class => 'inactive'}
    )
  end
  
  def selected? controller_name
    if params[:controller] == controller_name
      return :class => "selected"
    end
  end
end