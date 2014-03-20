require "./lib/output_setting"
require "./lib/output_setting_uploader_methods"

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include OutputSetting::UploaderMethods

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

  def version_names
    versions.keys
  end
end
