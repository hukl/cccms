# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  include ExceptionNotifiable
  include AuthenticatedSystem
    
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation
  
  before_filter :set_locale
  
  protected
  
    def set_locale
      I18n.locale = params[:locale].to_sym if params[:locale]
    end
end
