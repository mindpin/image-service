module Output
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend,  ClassMethods
  end

  module InstanceMethods
    def adaptive(dimension, value)
      manipulate! do |img|
        x = dimension.to_s == "height" ? "x" : ""

        img.adaptive_resize "#{x}#{value[0]}"
        img
      end
    end

    def limit_size(which, value)
      manipulate! do |img|
        height = img["height"]
        width  = img["width"]

        if "max" == which
          x = height > width ? "x" : ""
        end

        if "min" == which
          x = height > width ? "" : "x"
        end

        img.adaptive_resize "#{x}#{value[0]}"
        img
      end
    end
  end

  module ClassMethods
    def output(option = [])
      type  = option[0]
      value = option[1]

      version_name = version_name_from_option(option)

      version version_name do
        case type.to_s
        when /^adaptive_([a-z]*)$/
          process adaptive: [$1, value]
        when /^([a-z]*)_size$/
          process limit_size: [$1, value]
        when "fix"
          process resize_to_limit: value
        when "fill"
          process resize_to_fill: value
        end
      end
    end
  end
end
