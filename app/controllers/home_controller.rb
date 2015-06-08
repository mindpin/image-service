class HomeController < ApplicationController
  def index
    return render "/home/index" if user_signed_in?

    render "/home/login"
  end
end