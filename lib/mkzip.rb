class Mkzip
  def initialize(image_ids, opts={})
    @images = Image.find(image_ids)
  end

  def zip
    result = Mkzip.pfop(bucket: 'ddtest', key: @images.first.path, fops: build_fops)
    return result[1]['persistentId'] if result[0] == 200
    result
  end

  def build_fops
    url = @images.map{|image| "/url/#{Base64.encode64(image.url)}/alias/#{Base64.encode64(image.filename)}"}.join
    ["mkzip/2", url].join
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
