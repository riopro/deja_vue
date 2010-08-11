ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'
Bundler.setup

require 'deja_vue'

require 'rack/test'
require 'spec'
require 'spec/autorun'
require 'spec/interop/test'
require 'base64'

Spec::Runner.configure do |conf|
  conf.include Rack::Test::Methods
end

set :run, false
set :environment, :test

set :raise_errors, true
set :logging, false
