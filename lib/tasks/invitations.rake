namespace :invitations do

  desc "生成邀请码"

  task :create do
    puts "====: 生成邀请码"

    count = ENV['count'].to_i

    count.times do |i|
      code = randstr(16)
      Invitation.create(:code => code)

      p code
    end
    
     
    puts "====: 生成完毕."
  end



end
