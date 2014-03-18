require "./lib/output"
require "./lib/output_settings"

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include Output
  extend  OutputSettings::UploaderMethods

  apply_settings!

  storage :aliyun

  def filename=(filename)
    @_filename = filename
  end

  def filename
    @_filename
  end

  def store_dir
    "/images"
  end

  def cache_dir
    "/tmp/4ye_image_service"
  end
end
