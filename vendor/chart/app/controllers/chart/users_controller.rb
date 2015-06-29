module Chart
  class UsersController < Chart::ApplicationController
    def sign_stat
    end

    def sign_list
      @users = Chart::UserStat.list_of_sign_day(params[:time])
    end

    def sign_stat_data
      res = Chart::UserStat.sign_stat(params[:time])
      render :json => res
    end
  end
end
