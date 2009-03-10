class AdminController < ApplicationController
  before_filter :login_required

  def index
    @drafts = Page.find(:all, :include => [:node, :user], :conditions => ["nodes.draft_id = pages.id"])
  end
  
end
