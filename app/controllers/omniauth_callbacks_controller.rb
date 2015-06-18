class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def weibo
    _create_for_omniauth
  end


 def _create_for_omniauth
    auth_hash = request.env['omniauth.auth']
    uid = auth_hash["uid"]
    provider   = auth_hash["provider"]
    token      = auth_hash["credentials"]["token"]
    expires_at = auth_hash["credentials"]["expires_at"]
    expires    = auth_hash["credentials"]["expires"]
    avatar_url = auth_hash["extra"]["raw_info"]["avatar_large"]
    user_name  = auth_hash["info"]["nickname"]

    user_token = UserToken.where(
      :uid      => uid,
      :provider => provider
    ).first

    if user_token.blank?
      user_token = UserToken.create(
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
    user = user_token.user
    if user.blank?
      user = User.create!(
        :name => user_name,
        # :user_token => user_token ???????
        :user_tokens => [user_token]
      )
    end

    user.update_attributes(
      :name => user_name,
      :avatar_url => avatar_url
    )
    sign_in_and_redirect(:user, user)
  end
end