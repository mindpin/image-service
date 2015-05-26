module FileEntityCreateMethods
  extend ActiveSupport::Concern

  module ClassMethods
    # 下载 url 的文件，并上传到七牛
    def from_remote_url(url, user)
      uri = URI(url)
      ext = uri.path.split(".").last || "dat"
      token = randstr
      filename = "#{token}.#{ext}"
      key = File.join("/", ENV["QINIU_BASE_PATH"], filename)

      new_url = 'http://iovip.qbox.me/fetch/' + 
        Qiniu::Utils.urlsafe_base64_encode(url) + 
        '/to/' + 
        Qiniu::Utils.encode_entry_uri(ENV['QINIU_BUCKET'], key)

      Qiniu::HTTP.management_post(new_url)
      callback_body = _get_meta_from_remote(filename, key, user)
      from_qiniu_callback_body(callback_body)
    end

    # 通过七牛 HTTP API 获取文件原信息
    def _get_meta_from_remote(filename, key, user)
      base_info  = Qiniu.stat(ENV['QINIU_BUCKET'], key)
      fsize      = base_info["fsize"]
      mimeType   = base_info["mimeType"]

      # meta
      image_width   = ""
      image_height  = ""
      image_rgb     = ""
      avinfo_format = ""
      avinfo_total_bit_rate = ""
      avinfo_total_duration = ""
      avinfo_video_codec_name = ""
      avinfo_video_bit_rate   = ""
      avinfo_video_duration   = ""
      avinfo_height           = ""
      avinfo_width            = ""
      avinfo_audio_codec_name = ""
      avinfo_audio_bit_rate   = ""
      avinfo_audio_duration   = ""
      #

      case mimeType.split("/").first
      when "image"
        image_info   = Qiniu.image_info(_get_qiniu_url(filename))
        image_width  = image_info["width"]
        image_height = image_info["height"]

        code, ave = Qiniu::HTTP.api_get(_get_qiniu_url(filename) + '?imageAve')
        image_rgb = ave["RGB"]
      when "video"
        code, avinfo = Qiniu::HTTP.api_get(_get_qiniu_url(filename) + '?avinfo')
        avinfo_format           = avinfo["format"]["format_name"]
        avinfo_total_bit_rate   = avinfo["format"]["bit_rate"]
        avinfo_total_duration   = avinfo["format"]["duration"]

        avinfo_video_codec_name = avinfo["streams"][0]["codec_name"]
        avinfo_video_bit_rate   = avinfo["streams"][0]["bit_rate"]
        avinfo_video_duration   = avinfo["streams"][0]["duration"]
        avinfo_height           = avinfo["streams"][0]["height"]
        avinfo_width            = avinfo["streams"][0]["width"]

        avinfo_audio_codec_name = avinfo["streams"][1]["codec_name"]
        avinfo_audio_bit_rate   = avinfo["streams"][1]["bit_rate"]
        avinfo_audio_duration   = avinfo["streams"][1]["duration"]

      when "audio"
        code, avinfo = Qiniu::HTTP.api_get(_get_qiniu_url(filename) + '?avinfo')
        avinfo_total_bit_rate   = avinfo["format"]["bit_rate"]
        avinfo_total_duration   = avinfo["format"]["duration"]

        avinfo_audio_codec_name = avinfo["streams"][0]["codec_name"]
        avinfo_audio_bit_rate   = avinfo["streams"][0]["bit_rate"]
        avinfo_audio_duration   = avinfo["streams"][0]["duration"]

      end

      return { 
        bucket:       ENV["QINIU_BUCKET"], 
        key:          key, 
        fsize:        fsize, 
        endUser:      user.blank? ? nil : user.id.to_s, 
        mimeType:     mimeType,
        origin_file_name: filename,

        image_width:  image_width,
        image_height: image_height,
        image_rgb:    image_rgb, 
        avinfo_format: avinfo_format,
        avinfo_total_bit_rate:   avinfo_total_bit_rate,
        avinfo_total_duration:   avinfo_total_duration,
        avinfo_video_codec_name: avinfo_video_codec_name,
        avinfo_video_bit_rate:   avinfo_video_bit_rate,
        avinfo_video_duration:   avinfo_video_duration,
        avinfo_height:           avinfo_height,
        avinfo_width:            avinfo_width,
        avinfo_audio_codec_name: avinfo_audio_codec_name,
        avinfo_audio_bit_rate:   avinfo_audio_bit_rate,
        avinfo_audio_duration:   avinfo_audio_duration
      }
    end

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
    def from_qiniu_callback_body(callback_body)
      token      = callback_body[:key].match(/\/#{ENV['QINIU_BASE_PATH']}\/(.*)\..*/)[1]
      mime_type  = callback_body[:mimeType]
      meta = __get_meta_from_callback_body(mime_type, callback_body)
      kind = mime_type.split("/").first.to_sym
      if !FileEntity::KINDS.include?(kind)
        Qiniu.delete(ENV['QINIU_BUCKET'], callback_body[:key])
        raise '不允许上传 图片 音频 视频 以外类型的资源'
      end

      FileEntity.create!(
        user_id:  callback_body[:endUser] || nil,
        original: callback_body[:origin_file_name], 
        token: token, 
        mime: mime_type, 
        meta: meta,
        kind: kind
      )
    end

    def __get_meta_from_callback_body(mime_type, callback_body)
      case mime_type.split("/").first
      when "image"
        rgb   = callback_body[:image_rgb]
        rgba  = "rgba(#{rgb[2..3].hex},#{rgb[4..5].hex},#{rgb[6..7].hex},0)"
        hex   = "##{rgb[2..7]}"

        width      = callback_body[:image_width]
        height     = callback_body[:image_height]
        fsize      = callback_body[:fsize]
        
        return {
          "major_color" => {
            "rgba" => rgba, 
            "hex"  => hex
          }, 
          "height"   => height, 
          "width"    => width, 
          "filesize" => fsize
        }
      when "video"
        return {
          "avinfo" => {
            "format"                => callback_body[:avinfo_format],
            "total_bit_rate"        => callback_body[:avinfo_total_bit_rate],
            "total_duration"        => callback_body[:avinfo_total_duration],
            "video_codec_name"      => callback_body[:avinfo_video_codec_name],
            "video_bit_rate"        => callback_body[:avinfo_video_bit_rate],
            "video_duration"        => callback_body[:avinfo_video_duration],
            "height"                => callback_body[:avinfo_height],
            "width"                 => callback_body[:avinfo_width],
            "audio_codec_name"      => callback_body[:avinfo_audio_codec_name],
            "avinfo_audio_bit_rate" => callback_body[:avinfo_audio_bit_rate],
            "avinfo_audio_duration" => callback_body[:avinfo_audio_duration]
          },
          "filesize" => callback_body[:fsize] 
        }
      when "audio"
        {
          "avinfo" => {
            "total_bit_rate"   => callback_body[:avinfo_total_bit_rate],
            "total_duration"   => callback_body[:avinfo_total_duration],
            "audio_codec_name" => callback_body[:avinfo_audio_codec_name],
            "audio_bit_rate"   => callback_body[:avinfo_audio_bit_rate],
            "audio_duration"   => callback_body[:avinfo_audio_duration]
          },
          "filesize" => callback_body[:fsize]
        }
      else
        fsize = callback_body[:fsize]
        return {"filesize" => fsize}
      end
    end


  end
end