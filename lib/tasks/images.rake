namespace :images do
  desc "设置所有图片的颜色平均值"
  task :set_meta do
    begin
      puts "====: 开始设置"
      criteria = Image.where(meta: nil)
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
end
