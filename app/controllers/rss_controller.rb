class RssController < ApplicationController
  
  before_filter :authenticate, :only => :recent_changes
  before_filter :get_host
  
  def updates
    expires_in 31.minutes, :public => true
    
    @items = Page.heads.find_tagged_with(
      "update",
      :order => "published_at DESC",
      :limit => 20
    )
    
    respond_to do |format|
      format.xml {}
    end
  end

  def recent_changes
    @items = Page.all(
      :limit => 20,
      :order => "updated_at desc",
      :conditions => [ 
        "updated_at < ? AND updated_at > ?", Time.now, Time.now-14.days
      ]
    )
  end
  
  protected
    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == "recent" && password == "d@t3N+kLAu-23"
      end
    end
    
    def get_host
      @host = request.protocol + request.host_with_port
    end
  
end
