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
  field :old,      type: Boolean,  default: false
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

  def save_old_urls
    versions[1..-1].each do |version|
      self.old_urls = [] if !self.old_urls
      next if self.old_urls.include?(version.url)
      self.old_urls << version.url
    end

    save
  end

  def old_url(param)
    base = file.url.split(filename)[0]
    File.join(base, [param, filename].compact.join("_"))
  end

  def base
    File.join(R::IMAGE_ENDPOINT,
              R::ALIYUN_BASE_DIR,
              "images/#{token}",
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
      name   = array.select {|i| i.match /[a-zA-Z]+/}.join("_").to_sym
      @name  = name.blank? ? :raw : name
      @image = image
      @value = array.select {|i| i.match /[0-9]+/}.map(&:to_i)

      if image.old
        @url = image.old_url(version_def)
      else
        param = OutputSetting.translate(name, value)

        @url = image.new_url(param)
      end
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

Image.where(old: nil).update_all(old: true)
