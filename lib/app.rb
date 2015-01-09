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
require "mini_magick"
require 'kaminari/sinatra'
require "./lib/ext"
require "logger"

require "sinatra/cookies"

require 'omniauth'
require 'omniauth-weibo-oauth2'
require 'omniauth-qq'
require 'omniauth-github'
require 'dotenv'
Dotenv.load

require File.expand_path("../../config/env",__FILE__)

require './lib/user'
require './lib/user_token'
require "./lib/image"
require './lib/invitation'


enable :sessions


class ImageServiceApp < Sinatra::Base
  helpers Sinatra::Cookies

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
      provider :weibo, ENV['WEIBO_KEY'], ENV['WEIBO_SECRET']
      provider :qq_connect, ENV['QQ_CONNECT_KEY'], ENV['QQ_CONNECT_SECRET']
      provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
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
    serve "/lily", :from => "assets/lily" # 引用 lily 样式库
    serve "/futura", :from => "mobile-ui/css/fonts" # 引用 futura 字体

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

  def img_json(image)
    content_type :json
    JSON.generate({
      filename: image.filename, 
      url: image.raw.url,
      token: image.token
    }.merge(image.meta || {}))
  end


  get "/" do
    redirect '/login' unless current_user

    redirect '/check_invitation' unless current_user.is_activated

    haml :index
  end

  get "/check_invitation" do
    haml :check_invitation
  end

  post "/register_user" do
    if Invitation.where(code: params[:code], is_used: false).exists?
      invitation = Invitation.where(code: params[:code], is_used: false).first
      invitation.is_used = true
      invitation.save

      current_user.update_attributes(:is_activated => true)
      current_user.save
    end

    redirect '/'
  end

  get "/logout" do
    user_sign_out!
    redirect '/'
  end
  

  get "/zmkm" do
    haml :zmkm
  end

  get "/zmkm/images" do
    @images = Image.anonymous.order_by(created_at: -1)
      .page(params[:page]).per(100)
    haml :zmkm_images
  end

  get "/r/:token" do
    image = Image.find_by(token: params[:token])
    redirect to(image.file.url)
  end

  options "/zmkm/images" do
    200 
  end

  post "/zmkm/images" do
    if params[:base64]
      image = Image.from_base64 params[:base64]

    elsif params[:remote_url]
      image = Image.from_remote_url params[:remote_url]
    
    elsif params[:file]
      image = Image.from_params(params[:file])
    
    end

    img_json(image) if image
  end

  get "/settings" do
    haml :settings
  end

  ##
  # 私人图片
  options "/images" do
    200 
  end

  post "/images" do
    return status 401 if !user_signed_in?

    if params[:base64]
      image = Image.from_base64 params[:base64], current_user

    elsif params[:remote_url]
      image = Image.from_remote_url params[:remote_url], current_user
    
    elsif params[:file]
      image = Image.from_params params[:file], current_user
    
    end

    img_json(image) if image
  end

  get "/images" do
    return status 401 if !user_signed_in?

    @images = current_user.images.order_by(created_at: -1)
      .page(params[:page]).per(100)
    haml :images
  end
  ##

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

  post "/api/zmkm/upload" do
    image = Image.from_params(params[:file])
    img_json(image) if image
  end

  get "/api/images/:token" do
    img_json Image.find_by(token: params[:token])
  end

  get "/display" do
    @url = params[:url]
    haml :display
  end

  get "/login" do
    
    haml :login
  end

  get "/auth/github/callback" do
    build_oauth
    
    redirect "/"
  end


  get "/auth/weibo/callback" do
    build_oauth
    
    redirect "/"
  end


  get "/auth/qq/callback" do
    build_oauth
    
    redirect "/"
  end

  def build_oauth
    auth_hash = request.env['omniauth.auth']
    uid = auth_hash["uid"]
    provider   = auth_hash["provider"]
    token      = auth_hash["credentials"]["token"]
    expires_at = auth_hash["credentials"]["expires_at"]
    expires    = auth_hash["credentials"]["expires"]
    
    user_token = UserToken.where(
      :uid      => uid,
      :provider => provider
    ).first

    if user_token.blank?
      user = User.create!(:name => auth_hash[:info][:nickname])
      user_token = user.user_tokens.create(
        :uid        => uid,
        :provider   => provider,
        :token      => token,
        :expires_at => expires_at,
        :expires    => expires
      )
    else
      user_token.update_attributes(
        :token      => token,
        :expires_at => expires_at,
        :expires    => expires
      )
    end
    self.current_user = user_token.user
  end


  def current_user=(user)
    user_id = user.id.to_s
    cookies[:user_id] = user_id

  end

  def current_user
    user_id = cookies[:user_id]

    User.where(:id => user_id).last
  end

  def user_signed_in?
    !!current_user
  end

  def user_sign_out!
    cookies.delete :user_id
  end

end
