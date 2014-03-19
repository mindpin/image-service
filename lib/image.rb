require "./lib/image_uploader"

class Image
  include Mongoid::Document
  include Mongoid::Timestamps

  field :file,     type: String
  field :original, type: String
  field :token,    type: String
  field :versions, type: Array

  validate :file, :original, :filename, presence: true

  mount_uploader :file, ImageUploader

  alias :old_vers :versions

  def self.from_params(hash)
    image = self.new(token: randstr, original: hash[:filename])
    image.file = hash[:tempfile]
    image.versions = image.file.versions.keys
    image.save
    image
  end

  def filename
    "#{token}#{File.extname(original)}"
  end

  def versions
    old_vers.map do |version|
      array = version.to_s.split("_")
      name  = array.select {|i| i.match /[a-zA-Z]+/}.join("_").to_sym
      value = array.select {|i| i.match /[0-9]+/}.map(&:to_i)
      {name: name, value: value, url: url_template(version)}
    end
  end

  private

  def url_template(version)
    base = file.url.split("/")[0..-2].join("/")
    File.join(base, "#{version}_#{filename}")
  end
end
