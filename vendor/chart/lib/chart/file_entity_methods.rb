module Chart
  module FileEntityMethods
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # time_str => "2015-05"
      # result
      # {
      #   :time => "2015-05",
      #   :data => {
      #     "01" => {
      #       # 01 号 上传图片数量 10
      #       :count => 10
      #     },
      #     "02" => {
      #       # 02 号 上传图片数量 10
      #       :count => 10
      #     },
      #   }
      # }
      def image_upload_count_stat(time_str)
        day_str_list = Chart::TimeUtil.day_str_list_of_month_str(time_str)

        result = {
          time: time_str,
          data: {}
        }
        day_str_list.each do |day_str|
          start_time = Chart::TimeUtil.start_day_str_to_time(day_str)
          end_time   = Chart::TimeUtil.end_day_str_to_time(day_str)
          day = sprintf("%02d", start_time.day)

          count = FileEntity.images.where(:created_at.gte => start_time, :created_at.lt => end_time).count
          result[:data][day] = count
        end

        result
      end

    end
  end
end

begin
  FileEntity.send(:include, Chart::FileEntityMethods)
rescue NameError
  p "没有 FileEntity 类"
end
