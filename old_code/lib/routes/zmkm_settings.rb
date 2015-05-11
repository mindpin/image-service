class ImageServiceApp < Sinatra::Base
  get "/zmkm/settings" do
    haml :zmkm_settings
  end

  post "/zmkm/settings" do
    OutputSetting.set_public(params[:config])
    haml :zmkm_settings_partial, layout: false
  end

end