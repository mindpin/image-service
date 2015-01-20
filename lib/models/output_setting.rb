class OutputSetting
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,  type: String
  field :value, type: String

  validates :value, presence: true
  validates :name, presence: true

  belongs_to :user
  scope :anonymous, where(:user_id => nil)

  # config => [
  #    {name:'...', value:'...'},
  #    {name:'...', value:'...'}
  # ]
  def self.set_public(configs)
    self._set(OutputSetting.anonymous, configs)
  end

  # config => [
  #    {name:'...', value:'...'},
  #    {name:'...', value:'...'}
  # ]
  def self.set_private(configs, user)
    self._set(user.output_settings, configs)
  end

  def self._set(settings, configs)
    names = configs.map do |config|
      name =  config[:name]  || config["name"]
      value = config[:value] || config["value"]
      setting = settings.find_or_initialize_by(:name=>name)
      setting.value = value
      setting.save
      name
    end

    settings.each do |s|
      s.destroy if !names.include?(s.name)
    end
  end
end
