# coding: utf-8
class Image
  include Mongoid::Document
  include Mongoid::Timestamps

  field :original, type: String
  field :token,    type: String
  field :mime,     type: String
  field :meta,     type: Hash
  field :is_oss,   type: Boolean

  belongs_to :user
  scope :anonymous, -> {where(:user_id => nil)}
  validates :original, :token, :mime, :meta, presence: true

  # { "bucket"=>"fushang318", 
  #   "key"=>"/i/yscPYbwk.jpeg", 
  #   "fsize"=>"3514", 
  #   "endUser"=>"5551b62b646562104b000000", 
  #   "imageAve"=>"{\"RGB\":\"0xee4f60\"}", 
  #   "origin_file_name"=>"icon200x200.jpeg",
  #   "imageInfo"=>"{\"format\":\"png\",\"width\":200,\"height\":200,\"colorModel\":\"nrgba\"}"
  # }
  def self.from_qiniu_callback_body(callback_body)
    token = callback_body[:key].match(/\/#{ENV['QINIU_BASE_PATH']}\/(.*)\..*/)[1]

    rgb   = JSON.parse(callback_body[:imageAve])["RGB"]
    rgba  = "rgba(#{rgb[2..3].hex},#{rgb[4..5].hex},#{rgb[6..7].hex},0)"
    hex   = "##{rgb[2..7]}"

    image_info = JSON.parse(callback_body[:imageInfo])
    width      = image_info["width"]
    height     = image_info["height"]
    fsize      = callback_body[:fsize]

    origin_file_name = callback_body[:origin_file_name]

    mime_type = callback_body[:mimeType]

    user_id   = callback_body[:endUser] || nil

    Image.create!(
      user_id:  user_id,
      original: origin_file_name, 
      token: token, 
      mime: mime_type, 
      meta: {
        "major_color" => {
          "rgba" => rgba, 
          "hex"  => hex
        }, 
        "height"   => height, 
        "width"    => width, 
        "filesize" => fsize
      }
    )
  end
  # after_create :update_user_space

  # def update_user_space
  #   return unless self.user
  #   new_size = self.magick.tempfile.size 

  #   space_state = self.user.space_state
  #   if space_state
  #     current_size = space_state.space_size
  #     space_state.update_attributes(:space_size => current_size + new_size)
  #     space_state.save
  #     return
  #   end
    
  #   SpaceState.create(:user => self.user, :space_size => new_size)
  # end

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

  def versions
    if self.user.blank?
      image_sizes = ImageSize.anonymous
    else
      image_sizes = self.user.image_sizes
    end
    result = image_sizes.map{|image_size| Version.new(self, image_size)}
    result.unshift(Version.new(self, nil))
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
  end
end
