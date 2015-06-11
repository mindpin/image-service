class FileEntitiesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create, :uptoken_options]
  before_filter :set_access_control_headers, only: [:uptoken_options, :uptoken]
  def set_access_control_headers
    if !request.headers["Origin"].blank?
      response.headers['Access-Control-Allow-Origin']   = request.headers["Origin"]

      response.headers['Access-Control-Allow-Methods'] = "POST, GET, OPTIONS"
      response.headers['Access-Control-Allow-Headers'] = "X-Requested-With, Content-Type, Accept, If-Modified-Since"
      response.headers['Access-Control-Max-Age'] = "1728000"
    end
  end

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
    #   "image_height"=>"200",
    #   "avinfo_format" => "",
    #   "avinfo_total_bit_rate" => "",
    #   "avinfo_total_duration" => "",
    #   "avinfo_video_codec_name" => "",
    #   "avinfo_video_bit_rate"   => "",
    #   "avinfo_video_duration"   => "",
    #   "avinfo_height"           => "",
    #   "avinfo_width"            => "",
    #   "avinfo_audio_codec_name" => "",
    #   "avinfo_audio_bit_rate"   => "",
    #   "avinfo_audio_duration"   => ""
    # }
    file_entity = FileEntity.from_qiniu_callback_body(params)
    if !current_user.blank?
      render json: {
        id: file_entity.id.to_s,
        kind: file_entity.kind,
        url: file_entity.url,
        stat: {
          user_id:  current_user.id,
          image_count: current_user.file_entities.images.is_qiniu.count,
          space_used: current_user.qiniu_image_space_size.to_human_format_filesize
        }
      }
    else
      render json: {
        id: file_entity.id.to_s,
        kind: file_entity.kind,
        url: file_entity.url
      }
    end
  end

  def uptoken
    put_policy = Qiniu::Auth::PutPolicy.new(ENV['QINIU_BUCKET'])
    put_policy.callback_url = File.join(ENV['QINIU_CALLBACK_HOST'], "/file_entities")
    put_policy.callback_body = 'bucket=$(bucket)&key=$(key)&fsize=$(fsize)&endUser=$(endUser)&image_rgb=$(imageAve.RGB)&origin_file_name=$(x:origin_file_name)&mimeType=$(mimeType)&image_width=$(imageInfo.width)&image_height=$(imageInfo.height)&avinfo_format=$(avinfo.format.format_name)&avinfo_total_bit_rate=$(avinfo.format.bit_rate)&avinfo_total_duration=$(avinfo.format.duration)&avinfo_video_codec_name=$(avinfo.video.codec_name)&avinfo_video_bit_rate=$(avinfo.video.bit_rate)&avinfo_video_duration=$(avinfo.video.duration)&avinfo_height=$(avinfo.video.height)&avinfo_width=$(avinfo.video.width)&avinfo_audio_codec_name=$(avinfo.audio.codec_name)&avinfo_audio_bit_rate=$(avinfo.audio.bit_rate)&avinfo_audio_duration=$(avinfo.audio.duration)'
    if !current_user.blank?
      put_policy.end_user = current_user.id.to_s
    end
    uptoken = Qiniu::Auth.generate_uptoken(put_policy)
    render json: {
      uptoken: uptoken
    }
  end

  def uptoken_options
    render :text => 200, :status => 200
  end

  def batch_delete
    ids = params[:ids].split(",")
    current_user.file_entities.find(ids).each do |f|
      f.destroy
    end
    render json: {
      stat: {
        user_id:  current_user.id,
        image_count: current_user.file_entities.images.is_qiniu.count,
        space_used: current_user.qiniu_image_space_size.to_human_format_filesize
      }
    }
  rescue
    render :text => 500, :status => 500
  end

  def create_zip
    ids = params[:ids].split(",")
    mkzip = Mkzip.new ids
    task_id = mkzip.zip
    render json: {task_id: task_id}
  end

  def get_create_zip_task_state
    result = Mkzip.result params[:task_id]
    case result[1]["code"]
    when 0
      json = {state: "success", url: File.join(ENV["QINIU_DOMAIN"], result[1]["items"][0]["key"]) }
    when 3
      json = {state: "failure", url: ""}
    else
      json = {state: "processing", url: ""}
    end
    render json: json
  end

end