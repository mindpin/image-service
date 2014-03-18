require "./lib/image_uploader"

class Image
  include Mongoid::Document
  include Mongoid::Timestamps

  field :file,     type: String
  field :original, type: String
  field :token,    type: String

  validate :file, :original, :filename, presence: true

  mount_uploader :file, ImageUploader

  def self.from_params(hash)
    image = self.new(token: randstr, original: hash[:filename])
    image.file = hash[:tempfile]
    image.save
    image
  end

  def filename
    "#{token}#{File.extname(original)}"
  end
end
