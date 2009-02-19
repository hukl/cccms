class AdminController < ApplicationController

  def index
  end

  def switch_locale
    I18n.locale = params[:id].to_sym
    
    render :controller => 'nodes', :action => 'index'
  end
  
end
