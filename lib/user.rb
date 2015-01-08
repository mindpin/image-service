class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  has_many :user_tokens
  has_many :images
end