class ImageServiceApp < Sinatra::Base
  get "/settings" do
    return status 401 if !user_signed_in?
    haml :settings
  end

  post "/settings" do
    return status 401 if !user_signed_in?
    OutputSetting.set_private(params[:config], current_user)
    haml :settings_partial, layout: false
  end
end