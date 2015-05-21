class QueneStatus
  include Mongoid::Document
  include Mongoid::Timestamps
  extend Enumerize

  field :status,         type: String
  field :success_data,   type: Hash

  enumerize :status, in: [:processing, :success, :failure], default: :processing
end
