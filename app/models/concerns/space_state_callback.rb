module SpaceStateCallback
  extend ActiveSupport::Concern

  included do
    after_create :increase_user_space

    def increase_user_space
      return unless self.user
      new_size = self.filesize
      current_size = self.user.space_size
      self.user.update_attributes(:space_size => current_size + new_size)
    end

    after_destroy :decrease_user_space

    def decrease_user_space
      return unless self.user
      new_size = self.filesize
      current_size = self.user.space_size
      self.user.update_attributes(:space_size => current_size - new_size)
    end
  end

  module ClassMethods
  end
end
