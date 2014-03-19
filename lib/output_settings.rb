# -*- coding: utf-8 -*-
require "./lib/output_setting"

class OutputSettings
  class << self
    delegate :add, :del, :save, :options,
             to: :instance

    def names
      {
        single: {
          adaptive_width: "限定高度宽度自适应",
          adaptive_height: "限定宽度高度自适应",
          max_size: "限定最长边短边自适应",
          min_size: "限定最短边长边自适应"
        },

        pair: {
          fix: "限定宽高",
          fill: "拉伸/裁切到尺寸"
        }
      }
    end

    def names_without_type
      names[:single].merge names[:pair]
    end

    private

    def instance
      @instance ||= self.new
    end
  end

  def reload!
    ImageUploader.apply_settings!
    true
  end

  def options
    OutputSetting.all.map(&:option)
  end

  def add(attrs)
    option = format_attrs(attrs)
    raise InvalidSetting.new if !self.class.names_without_type.include?(option[0])
    OutputSetting.from_option(option)
    self
  end

  def del(attrs)
    option = format_attrs(attrs)
    OutputSetting.delete_option(option)
    ImageUploader.delete_version_from_option(option)
    self
  end

  private

  def format_attrs(attrs)
    [attrs[0].to_sym, attrs[1].map(&:to_i)]
  end

  class InvalidSetting < Exception; end

  module UploaderMethods
    def apply_settings!
      OutputSettings.options.each {|option| output option}
    end

    def version_name_from_option(option)
      value_exp = option[1].join("_")
      :"#{option[0]}_#{value_exp}"
    end

    def delete_version_from_option(option)
      versions.delete version_name_from_option(option)
    end
  end
end

