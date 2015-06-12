class Mkzip
  def initialize(file_entity_ids, opts={})
    @file_entity_ids = file_entity_ids
    @images = FileEntity.find(file_entity_ids)
  end

  def zip
    # 先查询缓存
    task_id = MkzipCache.new(@file_entity_ids).zip_cache
    return task_id if !task_id.blank?
    
    result = Mkzip.pfop(bucket: ENV['QINIU_BUCKET'], key: @images.first.path, fops: build_fops)
    if result[0] == 200
      task_id = result[1]['persistentId']
      MkzipCache.new(@file_entity_ids).set_zip_cache(task_id)
      return task_id
    end
    result
  end

  def build_fops
    url = @images.map{|image| "/url/#{Base64.encode64(image.url)}/alias/#{Base64.encode64(image.filename)}"}.join
    time_str = DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d-%H-%M-%S').to_s
    zip_name = "#{time_str}-#{randstr}.zip"
    zip_url = "#{ENV['QINIU_BUCKET']}:zip_temp/#{zip_name}"
    new_name_ops = "|saveas/#{Base64.encode64(zip_url)}"
    ["mkzip/2", url, new_name_ops].join
  end

  def self.result (persistent_id)
    # 先查询缓存
    res = MkzipCache.result_cache(persistent_id)
    return res if !res.blank?

    res = Mkzip.prefop persistent_id

    if res[1]["code"] == 0
      MkzipCache.set_result_cache(persistent_id, res)
    end

    res
  end

  protected
  def self.pfop (hash)
    Qiniu::Fop::Persistance.pfop hash
  end

  def self.prefop (persistent_id)
    Qiniu::Fop::Persistance.prefop persistent_id
  end
end
