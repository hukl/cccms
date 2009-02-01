module ContentHelper
  
  # 
  def date_for_page page
    page.published_at.to_s(:db) rescue page.created_at.to_s(:db)
  end
  
end
