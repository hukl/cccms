module AdminHelper
  
  def language_selector
    case I18n.locale
    when :de
      link_to 'Deutsch', edit_node_path(@node, :locale => :en)
    when :en
      link_to 'Deutsch', :locale => :de, :controller => params[:controller], :action => params[:action]
    end
  end
end