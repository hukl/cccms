class ApplicationController < ActionController::Base
  protect_from_forgery
  
  #  include ExceptionNotifiable
  #  include AuthenticatedSystem
  #    
  #  helper :all # include all helpers, all the time
  #  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  #
  #  # Scrub sensitive parameters from your log
  #  filter_parameter_logging :password, :password_confirmation
  #  
  #  before_filter :set_locale
  #  
  #  protected
  #  
  #    def set_locale
  #      if params[:locale] && I18n.available_locales.include?(params[:locale])
  #        I18n.locale = params[:locale].to_sym
  #      else
  #        params.delete(:locale)
  #      end
  #    end
  #  protect_from_forgery
  
end
