module Chart
  class TimeUtil
    class StringFormatError < StandardError;end

    # 返回 某个月的所有天
    # month_time_str => "2015-05"
    # 返回值 => ['2015-05-01','2015-05-31']
    def self.day_str_list_of_month_str(month_time_str)
      start_time = self.start_month_str_to_time(month_time_str)
      end_time   = self.end_month_str_to_time(month_time_str)

      time = start_time
      list = []
      while time < end_time
        list.push self.time_to_day_str(time)
        time += 1.day
      end
      list
    end

    # time  => time(2015-02-05 15:50:42 +0800)
    # 返回值 => "2015-02-05"
    def self.time_to_day_str(time)
      time.strftime("%Y-%m-%d")
    end

    # str   => '2014-12'
    # 返回值 => time(2014-12-01 00:00:00 +0800)
    def self.start_month_str_to_time(str)
      match_data = str.match(/^([0-9]{4})-(0[1-9]|1[0-2])$/)
      if match_data.blank?
        raise StringFormatError.new("时间字符串格式错误")
      end
      year  = match_data[1].to_i
      month = match_data[2].to_i
      begin
        time = Time.new(match_data[1], match_data[2],1,0,0,0,'+08:00')
      rescue
        raise StringFormatError.new("时间字符串格式错误")
      end
      if time.year != year
        raise StringFormatError.new("时间字符串格式错误")
      end
      if time.month != month
        raise StringFormatError.new("时间字符串格式错误")
      end
      time
    end

    # str   => '2014-12'
    # 返回值 => time(2015-01-01 00:00:00 +0800)
    def self.end_month_str_to_time(str)
      time = self.start_month_str_to_time(str)
      time + 1.month
    end

    # str   => '2015-02-05'
    # 返回值 => time(2015-02-05 00:00:00 +0800)
    def self.start_day_str_to_time(str)
      match_data = str.match(/^([0-9]{4})-(0[1-9]|1[0-2])-(0[1-9]|1[0-9]|2[0-9]|3[0-1])$/)
      if match_data.blank?
        raise StringFormatError.new("时间字符串格式错误")
      end
      year = match_data[1].to_i
      month = match_data[2].to_i
      day = match_data[3].to_i
      begin
        time = Time.new(year,month,day,0,0,0,"+08:00")
      rescue
        raise StringFormatError.new("时间字符串格式错误")
      end
      if time.year != year
        raise StringFormatError.new("时间字符串格式错误")
      end
      if time.month != month
        raise StringFormatError.new("时间字符串格式错误")
      end
      if time.day != day
        raise StringFormatError.new("时间字符串格式错误")
      end
      time
    end

    # str   => '2015-02-05'
    # 返回值 => time(2015-02-06 00:00:00 +0800)
    def self.end_day_str_to_time(str)
      time = self.start_day_str_to_time(str)
      time + 1.day
    end

  end
end
