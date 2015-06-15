Rails.application.routes.draw do
  devise_for :users,
    :path => "",
    :controllers => { :omniauth_callbacks => "omniauth_callbacks" }

  root 'home#index'

  # 查看阿里云旧文件
  get '/aliyun' => 'home#aliyun'

  # 查看文件详情
  get '/f/:id' => 'file_entities#show'

  match "/file_entities/uptoken", to: "file_entities#uptoken_options", via: :options
  resources :file_entities do
    get    :uptoken,      on: :collection
    delete :batch_delete, on: :collection

    # zip 下载
    post   :create_zip,                on: :collection
    get    :get_create_zip_task_state, on: :collection
  end

  resources :image_sizes

  namespace :api do
    resources :file_entities do
      post :input_from_remote_url_to_quene, on: :collection
      get  :get_from_remote_url_status,     on: :collection
    end
    get  "/auth_check",  to: "auth#check"
  end
end
