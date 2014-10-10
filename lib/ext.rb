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
