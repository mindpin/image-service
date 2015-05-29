Rails.application.routes.draw do
  devise_for :users, 
    :path => "",
    :controllers => { :omniauth_callbacks => "omniauth_callbacks" }

  root 'home#index'

  match "/file_entities/uptoken", to: "file_entities#uptoken_options", via: :options
  resources :file_entities do
    get   :uptoken,  on: :collection
  end

  namespace :api do
    resources :file_entities do
      post :input_from_remote_url_to_quene, on: :collection
      get  :get_from_remote_url_status,     on: :collection
    end
    get  "/auth_check",  to: "auth#check"
  end
end
