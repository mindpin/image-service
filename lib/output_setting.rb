class OutputSetting
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,  type: String
  field :value, type: Array

  validates :value, uniqueness: {scope: :name}

  def option
    [name.to_sym, value.map(&:to_i)]
  end

  def self.from_option(option)
    self.find_or_create_by(name: option[0], value: option[1])
  end

  def self.delete_option(option)
    setting = self.from_option(option)
    setting.destroy if setting.persisted?
  end
end
