module SpaceState
  extend ActiveSupport::Concern

  included do
    field :space_size, type: Integer, default: 0
  end

  def recount_space_size
    update_attribute :space_size, images.sum{|image| image.filesize}
  end

  module ClassMethods
  end
end
