class Api::AuthController < ApplicationController
  def check
    if !signed_in?
      return render nothing: true, status: 401
    end

    render json: {
      name: current_user.name,
      #avatar: current_user.avatar,
    }
  end

end
