# coding: utf-8
class Image
  include Mongoid::Document
  include Mongoid::Timestamps
  include SpaceStateCallback

  field :original, type: String
  field :token,    type: String
  field :mime,     type: String
  field :meta,     type: Hash
  field :is_oss,   type: Boolean

  belongs_to :user
  scope :anonymous, -> {where(:user_id => nil)}
  validates :original, :token, :mime, :meta, presence: true


  # 下载 url 的文件，并上传到七牛
  def self.from_remote_url(url, user)
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
    callback_body = self._get_meta_from_remote(filename, key, user)
    self.from_qiniu_callback_body(callback_body)
  end

  # 通过七牛 HTTP API 获取文件原信息
  def self._get_meta_from_remote(filename, key, user)
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
      image_info   = Qiniu.image_info(self._get_qiniu_url(filename))
      image_width  = image_info["width"]
      image_height = image_info["height"]

      code, ave = Qiniu::HTTP.api_get(self._get_qiniu_url(filename) + '?imageAve')
      image_rgb = ave["RGB"]
    when "video"
      code, avinfo = Qiniu::HTTP.api_get(self._get_qiniu_url(filename) + '?avinfo')
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
      code, avinfo = Qiniu::HTTP.api_get(self._get_qiniu_url(filename) + '?avinfo')
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
  def self.from_qiniu_callback_body(callback_body)
    token      = callback_body[:key].match(/\/#{ENV['QINIU_BASE_PATH']}\/(.*)\..*/)[1]
    mime_type  = callback_body[:mimeType]
    meta = self.__get_meta_from_callback_body(mime_type, callback_body)

    Image.create!(
      user_id:  callback_body[:endUser] || nil,
      original: callback_body[:origin_file_name], 
      token: token, 
      mime: mime_type, 
      meta: meta
    )
  end

  def self.__get_meta_from_callback_body(mime_type, callback_body)
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

  def is_image?
    self.mime.split("/").first == 'image'
  end

  def filesize
    self.meta["filesize"].to_i
  end

  def key
    File.join("/", ENV["QINIU_BASE_PATH"], filename)
  end

  def filename
    "#{token}#{ext}"
  end

  def ext
    File.extname(original).downcase
  end

  def url
    if self.is_oss?
      File.join(ENV['IMAGE_ENDPOINT'],
                ENV['ALIYUN_BASE_DIR'],
                "#{filename}")
    else
      self.class._get_qiniu_url(filename)
    end
  end

  def path
    if self.is_oss?
      File.join("/",ENV['ALIYUN_BASE_DIR'],
                "#{filename}")
    else
      File.join("/",ENV['QINIU_BASE_PATH'],
                "#{filename}")
    end
  end

  def versions
    if self.user.blank?
      image_sizes = ImageSize.anonymous
    else
      image_sizes = self.user.image_sizes
    end
    result = image_sizes.map{|image_size| Version.new(self, image_size)}
    result.unshift(Version.new(self, nil))
  end

  def version(image_size_id)
    if self.user.blank?
      image_sizes = ImageSize.anonymous
    else
      image_sizes = self.user.image_sizes
    end
    Version.new(self, image_sizes.find(image_size_id))
  end

  def self._get_qiniu_url(filename)
    File.join(ENV['QINIU_DOMAIN'],
              "@",
              ENV['QINIU_BASE_PATH'],
              "#{filename}")
  end

  def self.images_versions(image_ids, image_size_id)
    find(image_ids).map{|image| image.version(image_size_id)}
  end

  def self.images_to_html_by_ids_and_image_size_id(image_ids, image_size_id)
    find(image_ids).map{|image| image.version(image_size_id)}.map(&:to_html)
  end

  class Version
    attr_reader :name, :url
    def initialize(image, image_size)
      @image = image
      @image_size = image_size
      @name = _init_name
      @url  = _init_url
    end
    
    def _init_name
      return "原始图片" if @image_size.blank?
      @image_size.name
    end

    def _init_url
      return @image.url if @image_size.blank?
      return _get_oss_url if @image.is_oss?
      _get_qiniu_url
    end

    # 获取 aliyun oss 自定义尺寸图片url
    def _get_oss_url
      case @image_size.style
      when 'width_height'
        "#{@image.url}@#{@image_size.width}w_#{@image_size.height}h_1e_1c#{@image.ext}"
      when 'width'
        "#{@image.url}@#{@image_size.width}w#{@image.ext}"
      when 'height'
        "#{@image.url}@#{@image_size.height}h#{@image.ext}"
      end
    end

    # 获取 qiniu 云存储 自定义尺寸图片url
    def _get_qiniu_url
      case @image_size.style
      when 'width_height'
        "#{@image.url}?imageView2/1/w/#{@image_size.width}/h/#{@image_size.height}"
      when 'width'
        "#{@image.url}?imageView2/2/w/#{@image_size.width}"
      when 'height'
        "#{@image.url}?imageView2/2/h/#{@image_size.height}"
      end
    end

    def to_html
      case @image_size.style
      when 'width_height'
        "<img width='#{@image_size.width}' height='#{@image_size.height}' src='#{@url}' />"
      when 'width'
        "<img width='#{@image_size.width}' src='#{@url}' />"
      when 'height'
        "<img height='#{@image_size.height}' src='#{@url}' />"
      end
    end

    def ==(another)
      self.name == another.try(:name) and 
        self.url == another.try(:url)
    end
  end
end
