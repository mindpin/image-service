module SpaceStateCallback
  extend ActiveSupport::Concern

  included do
    after_create :increase_user_space

    def increase_user_space
      return unless self.user

      if self.kind.to_sym == :image && self.is_oss.blank?
        _increase_qiniu_image_space_size        
      end

      if [:audio, :video].include?(self.kind.to_sym)
        _increase_av_space_size
      end
    end

    def _increase_qiniu_image_space_size
      new_size = self.filesize.to_i
      current_size = self.user.qiniu_image_space_size
      self.user.update_attributes(:qiniu_image_space_size => current_size + new_size)
    end

    def _increase_av_space_size
      new_size = self.filesize.to_i
      current_size = self.user.av_space_size
      self.user.update_attributes(:av_space_size => current_size + new_size)
    end

    after_destroy :decrease_user_space

    def decrease_user_space
      return unless self.user

      if self.kind.to_sym == :image && self.is_oss.blank?
        _decrease_qiniu_image_space_size        
      end

      if [:audio, :video].include?(self.kind.to_sym)
        _decrease_av_space_size
      end
    end

    def _decrease_qiniu_image_space_size
      new_size = self.filesize.to_i
      current_size = self.user.qiniu_image_space_size
      self.user.update_attributes(:qiniu_image_space_size => current_size - new_size)
    end

    def _decrease_av_space_size
      new_size = self.filesize.to_i
      current_size = self.user.av_space_size
      self.user.update_attributes(:av_space_size => current_size - new_size)
    end

  end

  module ClassMethods
  end
end
