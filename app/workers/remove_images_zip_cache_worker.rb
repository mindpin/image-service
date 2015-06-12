class RemoveImagesZipCacheWorker
  # 单位秒
  EXPIRE_TIME = 60 * 60 * 2;
  include Sidekiq::Worker

  sidekiq_options queue: "remove_images_zip_cache", retry: false
  Sidekiq.logger.level == Logger::DEBUG

  def self.add_job(key)
    perform_in((EXPIRE_TIME + 120).seconds, key)
  end

  def perform(key)
    Qiniu.delete(ENV['QINIU_BUCKET'], key)
  rescue Exception => ex
    puts ex.message
    puts ex.backtrace*"\n"
  end
end