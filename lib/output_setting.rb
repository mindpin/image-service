# coding: utf-8
class OutputSetting
  NAMES = [
    :adaptive_width, :adaptive_height,
    :max_size, :min_size,
    :limit, :fill
  ]

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,  type: String
  field :value, type: Array

  validates :value, uniqueness: {scope: :name}
  validates :name,  inclusion: {in: NAMES.map(&:to_s)}

  def option
    [name.to_sym, value.map(&:to_i)]
  end

  def version_name
    %Q|#{name}_#{value.join("_")}|.to_sym
  end

  def cn
    self.class.names[name.to_sym]
  end

  def self.names
    Hash[NAMES.zip [
      "限定高度宽度自适应", "限定宽度高度自适应",
      "限定最长边短边自适应", "限定最短边长边自适应",
      "限定宽高", "拉伸/裁切到尺寸"
    ]]
  end

  def self.version_names
    self.all.map(&:version_name)
  end

  def self.options
    self.all.map(&:option)
  end

  def self.from(param)
    option = format_attrs param
    self.find_or_create_by(name: option[0], value: option[1])
  end

  def self.del(param)
    setting = self.from(param)
    setting.destroy if setting.persisted?
  end

  def self.format_attrs(option)
    [option[0].to_sym, option[1].map(&:to_i)]
  end
end
