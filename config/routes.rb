Rails.application.routes.draw do
  devise_for :users, 
    :path => "",
    :controllers => { :omniauth_callbacks => "omniauth_callbacks" }

  root 'home#index'

  resources :images do
    get :uptoken,  on: :collection
  end

  namespace :api do
    resources :images do
      post :input_from_remote_url_to_quene, on: :collection
      get  :get_from_remote_url_status,     on: :collection
    end
  end
end
