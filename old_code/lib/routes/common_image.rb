class ImageServiceApp < Sinatra::Base
  get "/r/:token" do
    image = Image.find_by(token: params[:token])
    redirect to(image.file.url)
  end

  get "/images/:token" do
    @image = Image.find_by(token: params[:token])
    haml :image
  end

  post "/images/:token/add_tags" do
    @image = Image.find_by(token: params[:token])
    if !@image.user.blank? && @image.user != current_user
      return status 401
    end

    tags = @image.add_tags(params[:tags])
    content_type :json
    JSON.generate(tags)
  end
end