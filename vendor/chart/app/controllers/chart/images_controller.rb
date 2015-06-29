module Chart
  class ImagesController < Chart::ApplicationController
    def upload_count_stat
    end

    def upload_count_stat_data
      res = Chart::FileEntityStat.image_upload_count_stat(params[:time])
      render :json => res
    end
  end
end
