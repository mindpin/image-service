class ImageServiceApp < Sinatra::Base
  post "/api/zmkm/upload" do
    image = Image.from_params(params[:file])
    img_json(image) if image
  end

  get "/api/images/:token" do
    img_json Image.find_by(token: params[:token])
  end

  get "/display" do
    @url = params[:url]
    haml :display
  end
end