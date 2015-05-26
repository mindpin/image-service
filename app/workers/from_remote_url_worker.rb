class FromRemoteUrlWorker
  include Sidekiq::Worker

  sidekiq_options queue: "from_remote_url", retry: false
  Sidekiq.logger.level == Logger::DEBUG

  def perform(url, user_id, quene_status_id)
    user = user_id.blank? ? nil : User.find(user_id)
    file_entity = FileEntity.from_remote_url(url, user)
    quene_status = QueneStatus.find(quene_status_id)
    quene_status.status = :success
    quene_status.success_data = {"file_entity_id" => file_entity.id.to_s}
    quene_status.save
  rescue Exception => ex
    quene_status.status = :failure
    quene_status.save
  end
end