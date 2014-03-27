class OutputSetting
  module UploaderMethods
    def self.included(base)
      base.send :include, InstanceMethods
      base.send :extend,  ClassMethods
    end

    module InstanceMethods
      def adaptive(dimension, value)
        manipulate! do |img|
          x = dimension.to_s == "height" ? "" : "x"

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
      def output(option)
        setting = OutputSetting.from(option)

        version setting.version_name do
          case setting.name.to_s
          when /^adaptive_([a-z]*)$/
            process adaptive: [$1, setting.value]
          when /^([a-z]*)_size$/
            process limit_size: [$1, setting.value]
          when "limit"
            process resize_to_limit: setting.value
          when "fill"
            process resize_to_fill: setting.value
          end
        end
      end

      def apply_settings!
        versions.delete_if do |version_name, _|
          !OutputSetting.version_names.include?(version_name)
        end

        OutputSetting.options.each {|option| output option}
      end
    end
  end
end
