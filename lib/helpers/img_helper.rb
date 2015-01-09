module ImgHelper
  def img_json(image)
    content_type :json
    JSON.generate({
      filename: image.filename, 
      url: image.raw.url,
      token: image.token
    }.merge(image.meta || {}))
  end
end