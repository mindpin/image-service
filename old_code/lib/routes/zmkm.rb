class ImageServiceApp < Sinatra::Base
  options "/zmkm/images" do
    200 
  end

  get "/zmkm" do
    haml :zmkm
  end

  get "/zmkm/images" do
    @images = Image.anonymous.order_by(created_at: -1)
      .page(params[:page]).per(100)
    haml :zmkm_images
  end
  
  post '/zmkm/images/flow-upload' do
    part_upload
  end

  post "/zmkm/images" do
    if params[:base64]
      image = Image.from_base64 params[:base64]

    elsif params[:remote_url]
      image = Image.from_remote_url params[:remote_url]
    
    elsif params[:file]
      image = Image.from_params(params[:file])
    
    end

    img_json(image) if image
  end
end