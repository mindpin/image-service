class SpaceState
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uid, type: String
  field :space_size, type: Integer, default: 0


  belongs_to :user



end