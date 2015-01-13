class ImageServiceApp < Sinatra::Base
  get "/zmkm/settings" do
    haml :zmkm_settings
  end

  post "/zmkm/settings" do
    OutputSetting.from_param(params[:option].to_a[0])
    haml :zmkm_settings_partial, layout: false
  end

  delete "/zmkm/settings" do
    OutputSetting.del_by_param(params[:option].to_a[0])
    "deleted"
  end
end