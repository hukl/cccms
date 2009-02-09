 module Auditing
  def self.included(base)
    ActiveRecord::Base.observers.each do |observer|
      observer = if observer.respond_to?(:to_sym)
        observer.to_s.camelize.constantize.instance
      elsif observer.respond_to?(:instance)
        observer.instance
      else
        raise ArgumentError, "#{observer} is an invalid class name"
      end
      base.around_filter(observer) if observer.is_a?(Auditing::Observer)
    end
  end
 
  class Observer < ActiveRecord::Observer
    attr_accessor :controller
 
    def before(controller)
      self.controller = controller
    end
 
    def after(controller)
      self.controller = nil
    end
  end
end