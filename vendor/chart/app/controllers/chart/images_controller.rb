module Chart
  class ImagesController < Chart::ApplicationController
    def upload_count_stat
    end

    def upload_count_stat_data
      # {
      #   :time => "2015-05",
      #   :data => {
      #     "01" => {
      #       # 01 号 上传图片数量 10
      #       :count => 10
      #     }
      #   }
      # }
      render :json => FileEntity.image_upload_count_stat(params[:time])
    end
  end
end
