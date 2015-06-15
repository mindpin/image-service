namespace "from_0.2_to_0.3" do
  desc "迁移 0.2 版本的数据到 0.3版本"
  task migrate: :environment do
    # if file entity count == 0 error
    if FileEntity.count == 0
        raise "请在 mongodb 里把 images 表名修改成 file_entities"
    end

    # old file entity add  is_oss true
    file_entities = FileEntity.all
    count = file_entities.count
    file_entities.each_with_index do |file_entity, index|
      begin
        p "#{index+1}/#{count}"
        file_entity.is_oss = true

        kind = file_entity.mime.split("/").first.to_sym
        if kind == "image"
          file_entity.kind = kind
          file_entity.save!
        end
      rescue
        p "忽略 #{file_entity}"
      end
    end

    p "迁移完成"

  end

end
