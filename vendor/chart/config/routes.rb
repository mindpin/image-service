Chart::Engine.routes.draw do
  get '/users/sign_stat' => 'users#sign_stat'
  get '/users/sign_stat_data'  => 'users#sign_stat_data'
  get '/users/sign_list' => 'users#sign_list'

  get '/images/upload_count_stat' => 'images#upload_count_stat'
  get '/images/upload_count_stat_data' => 'images#upload_count_stat_data'
end
