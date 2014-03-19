
Mongoid.load!("./config/mongoid.yml")

ENV_YAML_HASH = YAML.load_file(File.expand_path("../env.yml",__FILE__))

class R
  ALIYUN_BASE_DIR = ENV_YAML_HASH['ALIYUN_BASE_DIR']
end

CarrierWave.configure do |config|
  config.aliyun_access_id = ENV_YAML_HASH['ALIYUN_ACCESS_ID']
  config.aliyun_access_key = ENV_YAML_HASH['ALIYUN_ACCESS_KEY']
  config.aliyun_bucket = ENV_YAML_HASH['ALIYUN_BUCKET']
  config.aliyun_internal = false
  config.aliyun_area = ENV_YAML_HASH['ALIYUN_AREA']
end
