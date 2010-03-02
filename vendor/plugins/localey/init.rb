# Include hook code here

require 'localey'
require 'localey/route_set'

Rails.application.class.configure do
  config.middleware.use "Localey"
end