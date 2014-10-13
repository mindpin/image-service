class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes

  process :content_type_from_model!

  storage :aliyun

  after :store, :set_meta!

  def content_type_from_model!
    file.content_type = model.mime if model
  end

  def filename
    self.model.filename
  end

  def store_dir
    R::ALIYUN_BASE_DIR
  end

  def cache_dir
    "/tmp/4ye_image_service"
  end

  def set_meta!(file)
    model.set_meta!
  end
end
