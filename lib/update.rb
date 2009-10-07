module Update
  
  def self.find_or_create_parent
    current_year = Time.now.year.to_s
    
    if parent = Node.find_by_unique_name("updates/#{current_year}")
      parent
    else
      unless updates = Node.find_by_unique_name("updates")
        updates = Node.root.children.create(:slug => "updates")
      end
      parent = updates.children.create(:slug => current_year)
      parent
    end
  end
  
end