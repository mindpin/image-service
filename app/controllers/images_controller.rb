class ImagesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create

  def index
  end

  def new
  end

  def create
    # params 结构
    # { "bucket"=>"fushang318", 
    #   "key"=>"/i/yscPYbwk.jpeg", 
    #   "fsize"=>"3514", 
    #   "endUser"=>"5551b62b646562104b000000", 
    #   "image_rgb"=>"0xee4f60", 
    #   "origin_file_name"=>"icon200x200.jpeg",
    #   "mimeType" => "image/png",
    #   "image_width"=>"200",
    #   "image_height"=>"200"
    # }
    image = Image.from_qiniu_callback_body(params)
    render json: {
      id: image.id.to_s,
      is_image: image.is_image?,
      url: image.url
    }
  end

  def uptoken
    put_policy = Qiniu::Auth::PutPolicy.new(ENV['QINIU_BUCKET'])
    put_policy.callback_url = File.join(ENV['QINIU_CALLBACK_HOST'], "/images")
    put_policy.callback_body = 'bucket=$(bucket)&key=$(key)&fsize=$(fsize)&endUser=$(endUser)&image_rgb=$(imageAve.RGB)&origin_file_name=$(x:origin_file_name)&mimeType=$(mimeType)&image_width=$(imageInfo.width)&image_height=$(imageInfo.height)'
    if !current_user.blank?
      put_policy.end_user = current_user.id.to_s
    end
    uptoken = Qiniu::Auth.generate_uptoken(put_policy)
    render json: {
      uptoken: uptoken
    }
  end
end