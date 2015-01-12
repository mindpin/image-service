Mongoid.load!("./config/mongoid.yml")

ENV_YAML_HASH = YAML.load_file(File.expand_path("../env.yml",__FILE__))

class R
  ALIYUN_BASE_DIR = ENV_YAML_HASH['ALIYUN_BASE_DIR']
  IMAGE_ENDPOINT = ENV_YAML_HASH['IMAGE_ENDPOINT']
  GITHUB_KEY = ENV_YAML_HASH['GITHUB_KEY']
  GITHUB_SECRET = ENV_YAML_HASH['GITHUB_SECRET']
  WEIBO_KEY = ENV_YAML_HASH['WEIBO_KEY']
  WEIBO_SECRET = ENV_YAML_HASH['WEIBO_SECRET']
  QQ_CONNECT_KEY = ENV_YAML_HASH['QQ_CONNECT_KEY']
  QQ_CONNECT_SECRET = ENV_YAML_HASH['QQ_CONNECT_SECRET']
  TAGS_SERVICE = ENV_YAML_HASH['TAGS_SERVICE']
  TAG_SCOPE = ENV_YAML_HASH['TAG_SCOPE']
end

CarrierWave.configure do |config|
  config.aliyun_access_id = ENV_YAML_HASH['ALIYUN_ACCESS_ID']
  config.aliyun_access_key = ENV_YAML_HASH['ALIYUN_ACCESS_KEY']
  config.aliyun_bucket = ENV_YAML_HASH['ALIYUN_BUCKET']
  config.aliyun_internal = false
  config.aliyun_area = ENV_YAML_HASH['ALIYUN_AREA']
end
