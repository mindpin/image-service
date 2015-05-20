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
    res = Net::HTTP.get_response(uri)
    mine_type = res.header["Content-Type"]
    ext = mine_type.split("/").last

    token = randstr
    filename = "#{token}.#{ext}"
    key = File.join("/", ENV["QINIU_BASE_PATH"], filename)

    tf = Tempfile.new([randstr,".#{ext}"])
    tf.binmode
    tf << res.body
    tf.rewind

    put_policy = Qiniu::Auth::PutPolicy.new(ENV['QINIU_BUCKET'], key)
    put_policy.return_body = '{"key":$(key),"bucket":$(bucket),"key":$(key),"fsize":$(fsize),"origin_file_name":$(x:origin_file_name),"endUser":$(endUser),"image_rgb":$(imageAve.RGB),"mimeType":$(mimeType),"image_width":$(imageInfo.width),"image_height":$(imageInfo.height)}'
    if !user.blank?
      put_policy.end_user = user.id.to_s
    end
    uptoken = Qiniu::Auth.generate_uptoken(put_policy)

    code, result, response_headers = Qiniu::Storage.upload_with_put_policy(
        put_policy, tf, key, x_var = {"x:origin_file_name" => filename}
    )

    tf.close

    self.from_qiniu_callback_body(result.symbolize_keys)
  end

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
  def self.from_qiniu_callback_body(callback_body)
    token = callback_body[:key].match(/\/#{ENV['QINIU_BASE_PATH']}\/(.*)\..*/)[1]

    meta = self.__get_meta_from_callback_body(callback_body)

    origin_file_name = callback_body[:origin_file_name]

    mime_type = callback_body[:mimeType]

    user_id   = callback_body[:endUser] || nil

    Image.create!(
      user_id:  user_id,
      original: origin_file_name, 
      token: token, 
      mime: mime_type, 
      meta: meta
    )
  end

  def self.__get_meta_from_callback_body(callback_body)
    # 图片文件
    if !callback_body[:image_rgb].blank? && !callback_body[:image_width].blank?
      rgb   = callback_body[:image_rgb]
      rgba  = "rgba(#{rgb[2..3].hex},#{rgb[4..5].hex},#{rgb[6..7].hex},0)"
      hex   = "##{rgb[2..7]}"

      width      = callback_body[:image_width]
      height      = callback_body[:image_height]
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
      File.join(ENV['QINIU_DOMAIN'],
                "@",
                ENV['QINIU_BASE_PATH'],
                "#{filename}")
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
