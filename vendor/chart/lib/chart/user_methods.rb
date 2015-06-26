module Chart
  module UserMethods
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
      #       # 01 号 注册 10 人
      #       :count => 10
      #     },
      #     "02" => {
      #       # 02 号 注册 10 人
      #       :count => 10
      #     },
      #   }
      # }
      def sign_stat(time_str)
        day_str_list = Chart::TimeUtil.day_str_list_of_month_str(time_str)

        result = {
          time: time_str,
          data: {}
        }
        day_str_list.each do |day_str|
          start_time = Chart::TimeUtil.start_day_str_to_time(day_str)
          end_time   = Chart::TimeUtil.end_day_str_to_time(day_str)
          day = sprintf("%02d", start_time.day)

          count = User.where(:created_at.gte => start_time, :created_at.lt => end_time).count
          result[:data][day] = count
        end

        result
      end

      # time_str => "2015-05-01"
      # 返回值
      # [
      #   {
      #      :id    => xxx,
      #      :name  => xxx,
      #      :email => xxx,
      #   },
      # ]
      def list_of_sign_day(time_str)
        start_time = Chart::TimeUtil.start_day_str_to_time(time_str)
        end_time   = Chart::TimeUtil.end_day_str_to_time(time_str)
        users = User.where(:created_at.gte => start_time, :created_at.lt => end_time)
        users.map do |user|
          {
            id:    user.id.to_s,
            name:  user.name,
            email: user.email
          }
        end
      end
    end
  end
end

begin
  User.send(:include, Chart::UserMethods)
rescue NameError
  p "没有 User 类"
end
