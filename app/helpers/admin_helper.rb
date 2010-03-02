module AdminHelper
  
  def language_selector
    case I18n.locale
    when :de
      link_to 'English', content_path(:locale => :en)
    when :en
      link_to 'Deutsch', content_path(:locale => :de)
    end
  end
end