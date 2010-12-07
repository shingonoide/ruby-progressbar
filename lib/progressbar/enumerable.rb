# An extension to Enumerable allowing to automatically show a progress bar when looping.
# Does only work with the simplest syntax, like #each or #map without arguments, but that's usually sufficient 
#
# == Example:
#
#   [1,2,3].each_with_progressbar('title') { sleep(0.5} }
module Enumerable
  alias_method :method_missing_without_progressbar, :method_missing #:nodoc:

  def method_missing(name,*args) #:nodoc:
    if name.to_s =~ /_with_progressbar$/
      name_without_progressbar = name.to_s.gsub(/_with_progressbar$/, '')
      progressbar_title = args.shift || self.class.to_s+'#'+name_without_progressbar

      ProgressBar.block(progressbar_title, self.length) do |pbar|
        self.send(name_without_progressbar) do |*args| 
          yield(*args)
          pbar.inc
        end
      end
    else
      method_missing_without_progressbar(name, *args)
    end
  end
end
