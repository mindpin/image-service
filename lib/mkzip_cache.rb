require 'digest/sha1' 

class MkzipCache
  def initialize(ids)
    sha1_ids = Digest::SHA1.hexdigest(ids.sort.join(","))
    @key = "mkzip_cache:zip:#{sha1_ids}"
  end

  def zip_cache
    RedisInstance.instance.get(@key)
  end

  def set_zip_cache(persistent_id)
    ins = RedisInstance.instance
    ins.set(@key, persistent_id)
    ins.expire(@key, RemoveImagesZipCacheWorker::EXPIRE_TIME) # 两小时
  end

  def self.result_cache(persistent_id)
    key = "mkzip_cache:result:#{persistent_id}"
    res_str = RedisInstance.instance.get(key)
    return nil if res_str.blank?
    JSON.parse(res_str)
  end

  def self.set_result_cache(persistent_id, result)
    key = "mkzip_cache:result:#{persistent_id}"
    ins = RedisInstance.instance
    ins.set(key, result.to_json)
    ins.expire(key, RemoveImagesZipCacheWorker::EXPIRE_TIME) # 两小时
    key = result[1]["items"][0]["key"]
    RemoveImagesZipCacheWorker.add_job(key)
  end
end