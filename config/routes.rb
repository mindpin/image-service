Rails.application.routes.draw do
  devise_for :users, 
    :path => "",
    :controllers => { :omniauth_callbacks => "omniauth_callbacks" }

  root 'home#index'

  resources :images do
    get :uptoken,  on: :collection
  end
end
