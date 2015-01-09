namespace :invitations do

  desc "生成邀请码"

  task :create do
    puts "====: 生成邀请码"

    count = ENV['count'].to_i

    count.times do |i|
      Invitation.create(:code => randstr)
    end

    Invitation.all.each do |t|
      p t.code
    end
    
     
    puts "====: 生成完毕."
  end



end
