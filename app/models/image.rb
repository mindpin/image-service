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

  before_create :set_meta!
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

  def base
    File.join(R::IMAGE_ENDPOINT,
              R::ALIYUN_BASE_DIR,
              "#{filename}")
  end

  def new_url(param = nil)
    param ? "#{base}@#{param}#{ext}" : base
  end

  def magick
    location = self.new_record? ? self.file.path : self.raw.url
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

  def raw
    Version.new(self, nil)
  end

  def versions
    if self.user.blank?
      settings = OutputSetting.anonymous
    else
      settings = self.user.output_settings
    end
    result = settings.map{|setting| Version.new(self, setting)}
    result.unshift(Version.new(self, nil))
  end

  class Version
    attr_reader :name, :value, :url
    def initialize(image,setting)
      @setting = setting
      if setting.blank?
        @name  = "原始图片"
        @value = nil
        @url = image.new_url
      else
        @name  = setting.name
        @value = setting.value
        @url = image.new_url(@value)
      end
    end
  end
end
