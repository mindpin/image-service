# coding: utf-8
class ImageComment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content, type: String
  field :x,       type: Integer
  field :y,       type: Integer

  belongs_to :user
  belongs_to :file_entity

  validates :content, :x, :y, :user, :file_entity, presence: true

  def to_hash
    {
      :id             => id.to_s,
      :file_entity_id => file_entity.id.to_s,
      :user_id        => user.id.to_s,
      :x              => x,
      :y              => y,
      :content        => content
    }
  end

  module FileEntityMethods
    def self.included(base)
      base.has_many :image_comments
    end
  end
end
