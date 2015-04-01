class ImageServiceApp < Sinatra::Base
  options "/images" do
    200 
  end

  post '/images/flow-upload' do
    part_upload current_user
  end

  post "/images" do
    return status 401 if !user_signed_in?

    if params[:base64]
      image = Image.from_base64 params[:base64], current_user

    elsif params[:remote_url]
      image = Image.from_remote_url params[:remote_url], current_user
    
    elsif params[:file]
      image = Image.from_params params[:file], current_user
    
    end

    img_json(image) if image
  end

  get "/images" do
    return status 401 if !user_signed_in?

    @images = current_user.images.order_by(created_at: -1)
      .page(params[:page]).per(100)
    haml :images
  end
end