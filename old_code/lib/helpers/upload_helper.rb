module UploadHelper
  def part_upload(user = nil)
    begin
      file_name  = params[:flowFilename]
      file_size  = params[:flowTotalSize].to_i
      identifier = params[:flowIdentifier]

      # 尝试根据唯一标识找到文件
      file_entity = FilePartUpload::FileEntity.where(
          :identifier => identifier).first

      # 如果不存在，就创建一个
      if file_entity.blank?
        file_entity = FilePartUpload::FileEntity.new(
          :attach_file_name => file_name, 
          :attach_file_size => file_size,
          :identifier => identifier
        )
      end

      file_entity.save_blob params[:file][:tempfile]

      if file_entity.uploaded?
        file_entity.remove
        image = nil
        File.open(file_entity.attach.path) do |file|
          image = Image.from_params({
            :type => params[:file][:type],
            :tempfile => file,
            :filename => file_name
          }, user)
        end
        img_json(image) if image
      else
        'continue'
      end
    rescue Exception => e
      p e
      e.backtrace.each do |line|
        p line
      end
      500
    end
  end
end