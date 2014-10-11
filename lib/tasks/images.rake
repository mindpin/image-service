namespace :images do
  desc "设置所有图片的颜色平均值"
  task :set_meta do
    begin
      puts "====: 开始设置"
      criteria = Image.all
      total    = criteria.size

      criteria.each_with_index do |task, index|
        current = index + 1
        newline = current == total ? "\n" : "\r"

        task.set_meta!

        print "已完成(#{current}/#{total})#{newline}"
      end

      puts "====: 设置完毕."
    rescue Exception => ex
      puts ex.class
      puts ex.backtrace
      exit
    end
  end

  desc "拷贝所有图片到新的路径"
  task :migrate_path do
    not_found = []

    begin
      puts "====: 开始拷贝"
      criteria = Image.all
      total    = criteria.size

      criteria.each_with_index do |task, index|
        current = index + 1
        newline = current == total ? "\n" : "\r"

        begin
          old_path = File.join("#{task.raw.url.split('/i')[0]}",
                               "image_service",
                               "images/#{task.token}",
                               task.filename)

          task.file = open("http://img.4ye.me/hehe")
          task.save

          print "已完成(#{current}/#{total})#{newline}"
        rescue OpenURI::HTTPError
          not_found << task.id.to_s
          print "已完成(#{current}/#{total})#{newline}"
        end
      end

      puts "====: 以下图片不存在: #{not_found.join(",")}" if not_found.any?
      puts "====: 设置完毕."
    rescue Exception => ex
      puts ex.class
      puts ex.backtrace
      exit
    end
  end
end
