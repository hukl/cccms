module LinkHelper
  
  def link_to_path path
    url_for(
      :controller => :content,
      :action     => :render_page,
      :language   => I18n.locale,
      :page_path  => path
    )
  end
  
end