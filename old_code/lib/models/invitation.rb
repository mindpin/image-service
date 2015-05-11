class Invitation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :code, type: String
  field :is_used, type: Boolean, default: false

end