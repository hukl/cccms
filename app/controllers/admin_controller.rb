class AdminController < ApplicationController
  before_filter :login_required

  def index
    @drafts = Page.drafts
  end
  
end
