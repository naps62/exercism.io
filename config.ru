$:.unshift File.expand_path("./../lib", __FILE__)

require 'bundler'
Bundler.require

require 'app'
require 'api'
require 'sass/plugin/rack'

use Sass::Plugin::Rack
Sass::Plugin.options[:template_location] = "./lib/redesign/public/stylesheets/"
Sass::Plugin.options[:css_location] = "./lib/redesign/public/css"

ENV['RACK_ENV'] ||= 'development'

key = ENV['NEW_RELIC_LICENSE_KEY']
if key
  NewRelic::Agent.manual_start(license_key: key)
end

if ENV['RACK_ENV'].to_sym == :development
  require 'new_relic/rack/developer_mode'
  use NewRelic::Rack::DeveloperMode
end

use ActiveRecord::ConnectionAdapters::ConnectionManagement
run ExercismWeb::App

require 'legacy'
map '/api/v1/notifications' do
  # Notification endpoints are only used in the prototype.
  # Delete when redesign launches.
  run ExercismLegacy::App
end

map '/api/v1/' do
  run ExercismAPI::App
end


require 'redesign'
map '/redesign/' do
  run ExercismIO::Redesign
end
