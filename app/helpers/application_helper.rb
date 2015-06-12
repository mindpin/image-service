module ApplicationHelper
  def has_oss_file
    current_user.file_entities.images.is_oss.count > 0
  end
end
