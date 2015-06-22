# coding: utf-8
class ImageComment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text,    type: String
  field :x,       type: Integer
  field :y,       type: Integer

  belongs_to :user
  belongs_to :file_entity

  validates :text, :x, :y, :user, :file_entity, presence: true

  def to_hash
    hash = {
      :id             => id.to_s,
      :file_entity_id => file_entity.id.to_s,
      :x              => x,
      :y              => y,
      :text           => text
    }

    # 用户可能有被删除的
    if user.present?
      hash[:user] = {
        :id         => user.id.to_s,
        :name       => user.name,
        :avatar_url => user.avatar_url
      }
    end

    hash
  end

  module FileEntityMethods
    def self.included(base)
      base.has_many :image_comments
    end
  end
end
