module SpaceStateCallback
  extend ActiveSupport::Concern

  included do
    after_create :update_user_space

    def update_user_space
      return unless self.user
      new_size = self.meta['filesize']
      current_size = self.user.space_size
      self.user.update_attributes(:space_size => current_size + new_size)
    end
  end

  module ClassMethods
  end
end
