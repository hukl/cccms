class AdminController < ApplicationController
  before_filter :login_required

  def index
    @drafts = Page.find(
      :all, 
      :include => [:node, :user, :globalize_translations], 
      :conditions => ["nodes.draft_id = pages.id"]
    )
  end
  
end
