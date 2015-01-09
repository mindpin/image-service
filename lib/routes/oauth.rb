class ImageServiceApp < Sinatra::Base
  get "/login" do
    haml :login
  end

  get "/logout" do
    user_sign_out!
    redirect '/'
  end

  get "/auth/github/callback" do
    build_oauth
    redirect "/"
  end

  get "/auth/weibo/callback" do
    build_oauth
    redirect "/"
  end

  get "/auth/qq/callback" do
    build_oauth
    redirect "/"
  end

  def build_oauth
    auth_hash = request.env['omniauth.auth']
    uid = auth_hash["uid"]
    provider   = auth_hash["provider"]
    token      = auth_hash["credentials"]["token"]
    expires_at = auth_hash["credentials"]["expires_at"]
    expires    = auth_hash["credentials"]["expires"]
    
    user_token = UserToken.where(
      :uid      => uid,
      :provider => provider
    ).first

    if user_token.blank?
      user = User.create!(:name => auth_hash[:info][:nickname])
      user_token = user.user_tokens.create(
        :uid        => uid,
        :provider   => provider,
        :token      => token,
        :expires_at => expires_at,
        :expires    => expires
      )
    else
      user_token.update_attributes(
        :token      => token,
        :expires_at => expires_at,
        :expires    => expires
      )
    end
    self.current_user = user_token.user
  end
  
end