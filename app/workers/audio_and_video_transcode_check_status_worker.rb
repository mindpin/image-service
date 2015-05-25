class AudioAndVideoTranscodeCheckStatusWorker
  include Sidekiq::Worker

  sidekiq_options queue: "audio_and_video_transcode_check_status", retry: false
  Sidekiq.logger.level == Logger::DEBUG

  def perform(transcoding_record_id)
    tr = TranscodingRecord.find(transcoding_record_id)

    _, result = Qiniu::Fop::Persistance.prefop(tr.quniu_persistance_id)
    if result["code"] == 1 || result["code"] == 2
      # 两分钟后重新检查
      AudioAndVideoTranscodeCheckStatusWorker.perform_in(2.minutes, transcoding_record_id)
    elsif result["code"] == 0
      # 成功
      tr.status = :success
      tr.save
    else
      # 失败
      tr.status = :failure
      tr.save
    end
  end
end