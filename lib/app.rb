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
require "mini_magick"
require 'kaminari/sinatra'
require "logger"

require "sinatra/cookies"
require 'sinatra/partial'

require 'file-part-upload'

require 'omniauth'
require 'omniauth-weibo-oauth2'
require 'omniauth-qq'
require 'omniauth-github'

require File.expand_path("../../config/env",__FILE__)

require 'sinatra/flash'

enable :sessions

require "./lib/randstr"
require "./lib/ext"


class ImageServiceApp < Sinatra::Base
  register Sinatra::Partial
  
  helpers Sinatra::Cookies
  register Sinatra::Flash

  configure :development do
    register Sinatra::Reloader
  end

  Logger.class_eval { alias :write :'<<' }
  log_dir = File.join(File.dirname(File.expand_path("..", __FILE__)), "tmp", "logs")
  FileUtils.mkdir_p(log_dir) if !File.exists?(log_dir)
  access_log        = File.join(log_dir, "access.log")
  access_logger     = Logger.new(access_log)
  error_logger      = File.new(File.join(log_dir, "error.log"), "a+")
  error_logger.sync = true
 
  configure do
    use Rack::CommonLogger, access_logger

    use Rack::Session::Cookie
    use OmniAuth::Builder do
      provider :weibo, R::WEIBO_KEY, R::WEIBO_SECRET
      provider :qq_connect, R::QQ_CONNECT_KEY, R::QQ_CONNECT_SECRET
      provider :github, R::GITHUB_KEY, R::GITHUB_SECRET
    end

  end
 
  before {
    env["rack.errors"] =  error_logger
  }

  set :views, ["templates"]
  set :root, File.expand_path("../../", __FILE__)
  register Sinatra::AssetPack

  assets {
    serve "/js", :from => "assets/javascripts"
    serve "/css", :from => "assets/stylesheets"
    # 引用 lily 样式库
    serve "/lily", :from => "assets/lily" 
    # 引用 futura 字体
    serve "/futura", :from => "mobile-ui/css/futura" 
    # 引用 dreamspeak 字体
    serve "/dreamspeak", :from => "mobile-ui/css/dreamspeak"

    js :application, "/js/application.js", [
      '/js/lib/*.js',
      '/js/*.js'
    ]

    css :application, "/css/application.css", [
      "/css/ui.css"
    ]

    css_compression :yui
    js_compression  :uglify
  }

  before do
    headers("Access-Control-Allow-Origin" => "#{request.env["HTTP_ORIGIN"]}")
    headers("Access-Control-Allow-Credentials" => "true")
    headers("Access-Control-Allow-Methods" => "POST,GET,OPTIONS")
  end

  get "/" do
    redirect '/login' unless current_user
    # redirect '/check_invitation' unless current_user.is_activated

    p current_user.used_space_size
    p 'human size ========='
    p current_user.used_space_size_str
    haml :index
  end

end

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'