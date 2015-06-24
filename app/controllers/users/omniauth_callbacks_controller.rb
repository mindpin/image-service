class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def weibo
    user = User.from_weibo_omniauth(request.env['omniauth.auth'])
    sign_in_and_redirect(:user, user)
  end

  def qq_connect
    user = User.from_qq_connect_omniauth(request.env['omniauth.auth'])
    sign_in_and_redirect(:user, user)
  end
end
