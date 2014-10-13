# coding: utf-8
require "./lib/output_setting"
require "./lib/image_uploader"

class Image
  include Mongoid::Document
  include Mongoid::Timestamps

  field :file,     type: String
  field :original, type: String
  field :token,    type: String
  field :versions, type: Array
  field :mime,     type: String
  field :meta,     type: Hash

  validate :file, :original, :filename, presence: true

  mount_uploader :file, ImageUploader

  after_create :set_meta!

  alias :old_vers :versions

  def self.from_params(hash)
    image = self.new(token: randstr, original: hash[:filename])
    image.mime = hash[:type]
    image.file = hash[:tempfile]
    image.versions = OutputSetting.version_names
    image.save
    image
  end

  # 从传入的 base64 字符串构建并保存图片对象
  # base64 字符串形如：
  # data:image/png;base64, ....
  def self.from_base64(base64_str)
    idx = base64_str.index(',') + 1 
    png_data = Base64.decode64 base64_str[idx .. -1]

    tempfile = Tempfile.new 'tmp'
    begin
      tempfile.write png_data
      image = self.new(token: randstr, original: "paste-#{(Time.now.to_f * 1000).to_i}.png")
      image.mime = 'image/png'
      image.file = tempfile
      image.versions = OutputSetting.version_names
      image.save
    ensure
      tempfile.close
      tempfile.unlink
    end

    image
  end

  # 从传入的远程网址读取图片文件
  def self.from_remote_url(remote_url)
    tempfile = open remote_url
    image = self.new(token: randstr, original: "remote-#{(Time.now.to_f * 1000).to_i}.png")
    image.mime = 'image/png'
    image.file = tempfile
    image.versions = OutputSetting.version_names
    image.save
    image
  end

  def filename
    "#{token}#{ext}"
  end

  def ext
    File.extname(original).downcase
  end

  def versions
    [raw].concat(old_vers.map do |version|
      Version.new(self, version)
    end)
  end

  def raw
    Version.new(self, nil)
  end

  def base
    File.join(R::IMAGE_ENDPOINT,
              R::ALIYUN_BASE_DIR,
              "#{filename}")
  end

  def new_url(param)
    param ? "#{base}@#{param}#{ext}" : base
  end

  def magick
    @magick ||= MiniMagick::Image.open(self.raw.url)
  end

  def set_meta!
    self.meta = {
      major_color: magick.histogram,
      height: magick[:heigh],
      width: magick[:width],
      filesize: magick.tempfile.size,
    }

    self.save
  rescue OpenURI::HTTPError
    false
  end

  class Version
    attr_reader :name, :value, :url, :image

    def initialize(image, version_def)
      array  = version_def ? version_def.to_s.split("_") : []
      vname  = array.select {|i| i.match(/[a-zA-Z]+/)}.join("_").to_sym
      @name  = vname.blank? ? :raw : vname
      @image = image
      @value = array.select {|i| i.match(/[0-9]+/)}.map(&:to_i)

      param = version_def && OutputSetting.translate(name, value)
      @url = image.new_url(param)
    end

    def cn
      OutputSettings.names[name] || "原始图片"
    end

    def html
      %Q|<img src="#{url}" />|
    end

    def markdown
      %Q|![](#{url})|
    end
  end
end
