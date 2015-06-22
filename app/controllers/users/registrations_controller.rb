class Users::RegistrationsController < Devise::RegistrationsController
  def new
    redirect_to '/'
  end

  def create
    user = User.new(
      :name => params[:user][:name],
      :email => params[:user][:email],
      :password => params[:user][:password],
      :avatar_url => 'http://i.teamkn.com/i/bcfWnZG2.png'
    )
    if user.save
      sign_up :user, user
      render :status => 200, :json => {}
    else
      render :status => 422, :json => user.errors.map {|k, v|
        v
      }
    end
  end
end