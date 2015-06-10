class Mkzip
  def initialize(file_entity_ids, opts={})
    @images = FileEntity.find(file_entity_ids)
  end

  def zip
    result = Mkzip.pfop(bucket: ENV['QINIU_BUCKET'], key: @images.first.path, fops: build_fops)
    return result[1]['persistentId'] if result[0] == 200
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
    Mkzip.prefop persistent_id
  end

  protected
  def self.pfop (hash)
    Qiniu::Fop::Persistance.pfop hash
  end

  def self.prefop (persistent_id)
    Qiniu::Fop::Persistance.prefop persistent_id
  end
end
