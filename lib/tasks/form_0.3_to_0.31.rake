namespace "from_0.3_to_0.31" do
  desc "补充 user.created_at 字段"
  task add_user_timestamps: :environment do

    users = User.all
    count = users.count
    users.each_with_index do |user, index|
      begin
        p "#{index+1}/#{count}"

        user_token = user.user_tokens.first
        next if user_token.blank?

        user.created_at = user_token.created_at
        user.updated_at = user_token.updated_at
        user.save
      rescue
        p "忽略 #{user}"
      end
    end

    p "迁移完成"

  end

end
