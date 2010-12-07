class ProgressBar
  module DisplayWidthReader
    def get_width
      # FIXME: I don't know how portable it is.
      default_width = 80
      begin
        tiocgwinsz = 0x5413
        data = [0, 0, 0, 0].pack("SSSS")
        if @out.ioctl(tiocgwinsz, data) >= 0 then
          rows, cols, xpixels, ypixels = data.unpack("SSSS")
          if cols >= 0 then cols else default_width end
        else
          default_width
        end
      rescue Exception
        default_width
      end
    end
  end
end
