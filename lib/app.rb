require "./lib/randstr"
require "bundler"
Bundler.setup(:default)
require "sinatra"
require "sinatra/reloader"
require 'sinatra/assetpack'
require "pry"
require "sinatra"
require 'haml'
require 'sass'
require 'coffee_script'
require 'yui/compressor'
require 'sinatra/json'
require 'carrierwave'
require 'mongoid'
require 'carrierwave/mongoid'
require 'carrierwave-aliyun'
require "carrierwave_backgrounder"
require File.expand_path("../../config/env",__FILE__)

require "./lib/image"

class ImageServiceApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  set :views, ["templates"]
  set :root, File.expand_path("../../", __FILE__)
  register Sinatra::AssetPack

  assets {
    serve '/js', :from => 'assets/javascripts'
    serve '/css', :from => 'assets/stylesheets'

    js :application, "/js/application.js", [
      '/js/jquery-1.11.0.min.js',
      '/js/**/*.js'
    ]

    css :application, "/css/application.css", [
      '/css/**/*.css'
    ]

    css_compression :yui
    js_compression  :uglify
  }

  before do
    headers("Access-Control-Allow-Origin" => "#{request.env['HTTP_ORIGIN']}")
    headers("Access-Control-Allow-Credentials" => "true")
    headers("Access-Control-Allow-Methods" => "POST,GET,OPTIONS")
  end
  
  get "/" do
    haml :index
  end

  get "/images" do
    @images = Image.all.sort(created_at: -1)
    haml :images
  end

  get "/r/:token" do
    image = Image.find_by(token: params[:token])
    redirect to(image.file.url)
  end

  options "/images" do
    200 
  end

  post "/images" do
    image = Image.from_params(params[:file])
    content_type :json
    JSON.generate show: "/images/#{image.token}", orig: "http://#{request.host_with_port}/r/#{image.token}"
  end

  get "/settings" do
    haml :settings
  end

  post "/settings" do
    OutputSetting.from(params[:option].to_a[0])
    haml :settings_partial, layout: false
  end

  delete "/settings" do
    OutputSetting.del(params[:option].to_a[0])
    "deleted"
  end

  get "/images/:token" do
    @image = Image.find_by(token: params[:token])
    haml :image
  end

  get "/display" do
    @url = params[:url]
    haml :display
  end
end
