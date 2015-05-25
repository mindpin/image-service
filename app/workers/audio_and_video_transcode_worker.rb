class AudioAndVideoTranscodeWorker
  include Sidekiq::Worker

  sidekiq_options queue: "audio_and_video_transcode", retry: false
  Sidekiq.logger.level == Logger::DEBUG

  def perform(transcoding_record_id)
    tr = TranscodingRecord.find(transcoding_record_id)
    code = Qiniu::Utils.urlsafe_base64_encode("#{ENV['QINIU_BUCKET']}:#{tr.qiniu_key}")
    saveas_fops = "#{tr.fops}|saveas/#{code}"
    _, result = Qiniu::Fop::Persistance.pfop(
      bucket: ENV['QINIU_BUCKET'],
      key: tr.image.key, 
      fops: saveas_fops
    )
    tr.quniu_persistance_id = result["persistentId"]
    tr.save
    AudioAndVideoTranscodeCheckStatusWorker.perform_async(tr.id.to_s)
  end
end