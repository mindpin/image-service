require "./lib/output_setting"
require "./lib/output_setting_uploader_methods"

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::Backgrounder::Delay
  include OutputSetting::UploaderMethods
  include CarrierWave::MimeTypes

  process :content_type_from_model!

  apply_settings!

  storage :aliyun

  def content_type_from_model!
    file.content_type = model.mime if model
  end

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
