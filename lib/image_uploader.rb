require "./lib/output"
require "./lib/output_settings"

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include Output
  extend  OutputSettings::UploaderMethods

  apply_settings!

  storage :aliyun

  def filename
    self.model.filename
  end

  def store_dir
    File.join(R::ALIYUN_BASE_DIR, "images/#{model.token}")
  end

  def cache_dir
    "/tmp/4ye_image_service"
  end
end
