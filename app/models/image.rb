# coding: utf-8
class Image
  include Mongoid::Document
  include Mongoid::Timestamps


  field :file,     type: String
  field :original, type: String
  field :token,    type: String
  field :mime,     type: String
  field :meta,     type: Hash
  field :is_oss,   type: Boolean

  belongs_to :user
  scope :anonymous, -> {where(:user_id => nil)}
  validates :file, :original, :filename, presence: true

  # mount_uploader :file, ImageUploader

  # before_create :set_meta!
  after_create :update_user_space

  def update_user_space
    return unless self.user
    new_size = self.magick.tempfile.size 

    space_state = self.user.space_state
    if space_state
      current_size = space_state.space_size
      space_state.update_attributes(:space_size => current_size + new_size)
      space_state.save
      return
    end
    
    SpaceState.create(:user => self.user, :space_size => new_size)
    
    
  end

  def self.from_params(hash, user = nil)
    image = self.new(token: randstr, original: hash[:filename])
    image.mime = hash[:type]
    image.file = hash[:tempfile]
    if !user.blank?
      image.user = user
    end
    image.save
    image
  end

  # 从传入的 base64 字符串构建并保存图片对象
  # base64 字符串形如：
  # data:image/png;base64, ....
  def self.from_base64(base64_str, user = nil)
    idx = base64_str.index(',') + 1 
    png_data = Base64.decode64 base64_str[idx .. -1]

    tempfile = Tempfile.new 'tmp'
    begin
      tempfile.write png_data
      image = self.new(token: randstr, original: "paste-#{(Time.now.to_f * 1000).to_i}.png")
      image.mime = 'image/png'
      image.file = tempfile
      if !user.blank?
        image.user = user
      end
      image.save
    ensure
      tempfile.close
      tempfile.unlink
    end

    image
  end

  # 从传入的远程网址读取图片文件
  def self.from_remote_url(remote_url, user = nil)
    tempfile = open remote_url
    image = self.new(token: randstr, original: "remote-#{(Time.now.to_f * 1000).to_i}.png")
    image.mime = 'image/png'
    image.file = tempfile
    if !user.blank?
      image.user = user
    end
    image.save
    image
  end

  def filename
    "#{token}#{ext}"
  end

  def ext
    File.extname(original).downcase
  end

  def url
    File.join(ENV['IMAGE_ENDPOINT'],
              ENV['ALIYUN_BASE_DIR'],
              "#{filename}")
  end

  def magick
    location = self.new_record? ? self.file.path : self.url
    @magick ||= MiniMagick::Image.open(location)
  end

  def set_meta!
    self.meta = {
      major_color: magick.histogram,
      height: magick[:height],
      width: magick[:width],
      filesize: magick.tempfile.size,
    }

    self.save if !self.new_record?
  rescue MiniMagick::Error
    self.meta = {
      major_color: {hex: "#000000", rgba: "rgba(0,0,0,1)"},
      height: 100,
      width: 100,
      filesize: 0
    }

    self.save if !self.new_record?
  rescue OpenURI::HTTPError
    false
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
