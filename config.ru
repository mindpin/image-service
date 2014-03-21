require "./lib/app"
require "sidekiq/web"

run Rack::URLMap.new "/sidekiq" => Sidekiq::Web.new, "/" => ImageServiceApp.new
