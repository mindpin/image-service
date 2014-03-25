CarrierWave::Workers::ProcessAsset.class_eval {include ::Sidekiq::Worker}
CarrierWave::Workers::StoreAsset.class_eval {include ::Sidekiq::Worker}

class ProcessWorker < CarrierWave::Workers::ProcessAsset
  def perform(*args)
    ImageUploader.apply_settings!
    super(*args)
  end
end

class StoreWorker < CarrierWave::Workers::StoreAsset
  def perform(*args)
    ImageUploader.apply_settings!
    super(*args)
  end
end
