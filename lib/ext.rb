module MiniMagick
  class Image
    def histogram
      @histogram ||= proc {
        regexp = /^.*\:\s*\([\d\s\,]*\)\s*(?<hex>\#\h*)\s*(?<rgba>.*)$/

        raw = run_command(:convert,
                          path,
                          "-format",
                          "%c",
                          "-colors",
                          1,
                          "-depth",
                          8,
                          "-colorspace",
                          "RGB",
                          "-alpha",
                          "On",
                          "histogram:info:").strip.match(regexp)

        {
          :rgba => raw[:rgba],
          :hex  => raw[:hex][0, 7]
        }
      }.call
    end

    def tempfile
      @tempfile
    end
  end
end





# todo: 猴子补丁，暂时放在这里

class Integer
  def to_human_format
    {
      'B'  => 1024,
      'KB' => 1024 * 1024,
      'MB' => 1024 * 1024 * 1024,
      'GB' => 1024 * 1024 * 1024 * 1024,
      'TB' => 1024 * 1024 * 1024 * 1024 * 1024
    }.each_pair { |e, s| return "#{(self.to_f / (s / 1024)).round(2)}#{e}" if self < s }
  end
end