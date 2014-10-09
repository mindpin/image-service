module MiniMagick
  class Image
    def histogram
      @histogram ||= proc {
        regexp = /^.*\:\s*\([\d\s\,]*\)\s*(?<hex>\#\h*)\s*srgba\((?<rgba>.*)\)$/

        raw = run_command(:convert,
                          path,
                          "-format",
                          "%c\n",
                          "-colors",
                          1,
                          "-depth",
                          8,
                          "histogram:info:").match(regexp)

        {
          :rgba => raw[:rgba].split(","),
          :hex  => raw[:hex][0..-3]
        }
      }.call
    end
  end
end
