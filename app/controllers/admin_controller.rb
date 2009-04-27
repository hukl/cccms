class AdminController < ApplicationController
  before_filter :login_required

  def index
    @drafts = Page.drafts
    @recent_changes = Node.all(
      :limit => 50,
      :order => "updated_at desc",
      :conditions => [ 
        "updated_at < ? AND updated_at > ?", Time.now, Time.now-14.days
      ]
    )
  end
  
end
