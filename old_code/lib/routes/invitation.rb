class ImageServiceApp < Sinatra::Base
  get "/check_invitation" do
    haml :check_invitation
  end

  post "/register_user" do
    if Invitation.where(code: params[:code], is_used: false).exists?
      invitation = Invitation.where(code: params[:code], is_used: false).first
      invitation.is_used = true
      invitation.save

      current_user.update_attributes(:is_activated => true)
      current_user.save
    else
      flash[:error] = "邀请码不正确或者已经被使用"
      redirect '/check_invitation'
    end

    redirect '/'
  end
end