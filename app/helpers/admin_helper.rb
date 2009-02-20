module AdminHelper
  
  def language_selector
    case I18n.locale
    when :de
      link_to 'English', url_for(:locale => :en)
    when :en
      link_to 'Deutsch', url_for(:locale => :de)
    end
  end
end