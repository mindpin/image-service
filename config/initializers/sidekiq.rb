Sidekiq.configure_server do |config|
  config.options[:queues] = %w{from_remote_url audio_and_video_transcode audio_and_video_transcode_check_status remove_images_zip_cache}
  config.redis = {url: "redis://localhost:6379"}
end

Sidekiq.configure_client do |config|
  config.redis = {url: "redis://localhost:6379"}
end
