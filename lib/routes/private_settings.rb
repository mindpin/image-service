class ImageServiceApp < Sinatra::Base
  get "/settings" do
    return status 401 if !user_signed_in?
    haml :settings
  end

  post "/settings" do
    return status 401 if !user_signed_in?
    current_user.output_settings.from_param(params[:option].to_a[0])
    haml :settings_partial, layout: false
  end

  delete "/settings" do
    current_user.output_settings.del_by_param(params[:option].to_a[0])
    "deleted"
  end
end