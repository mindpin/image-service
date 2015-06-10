namespace "recount" do
  desc "重新计算用户占用空间"
  task space_state: :environment do

    users = User.all
    count = users.count
    users.each_with_index do |user, index|
        p "#{index+1}/#{count}"
        user.recount_space_size
    end

    p "recount space_state success!"
  end

end
