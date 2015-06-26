module Chart
  class UsersController < Chart::ApplicationController
    def sign_stat
    end

    def sign_stat_data
      # {
      #   :time => "2015-05",
      #   :data => {
      #     "01" => {
      #       # 01 号 注册 10 人
      #       :count => 10
      #     }
      #   }
      # }
      render :json => User.sign_stat(params[:time])
    end
  end
end
