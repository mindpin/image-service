class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :is_activated, type: Boolean, default: false


  has_many :user_tokens
  has_many :images
end