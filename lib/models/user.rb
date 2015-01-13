class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :is_activated, type: Boolean, default: false


  has_many :user_tokens
  has_many :images
  has_many :output_settings
  has_one :space_state


  def used_space_size
    return 0 unless self.space_state

    self.space_state.space_size
  end

  def used_space_size_str
    self.used_space_size.to_human_format_filesize
  end

end