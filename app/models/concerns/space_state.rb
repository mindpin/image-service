module SpaceState
  extend ActiveSupport::Concern

  included do
    field :qiniu_image_space_size, type: Integer, default: 0
    field :av_space_size,          type: Integer, default: 0
  end

  def recount_space_size
    _recount_av_space_size
    _recount_qiniu_image_space_size
  end

  def _recount_qiniu_image_space_size
    size = self.file_entities.is_qiniu.images.sum{|file_entity| file_entity.filesize}
    update_attribute :qiniu_image_space_size, size
  end

  def _recount_av_space_size
    size = self.file_entities.avs.sum{|file_entity| file_entity.filesize}
    update_attribute :av_space_size, size
  end

  module ClassMethods
  end
end
