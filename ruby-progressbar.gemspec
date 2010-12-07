require 'date'

Gem::Specification.new do |s|
  s.name = "ruby-progressbar"
  s.version = "0.1.0"

  s.authors = ["Satoru Takabayashi", 'Leonid Shevtsov']
  s.date = Date.today.to_s
  s.description = "Ruby/ProgressBar is a text progress bar library for Ruby."
  s.email = "leonid@shevtsov.me"
  s.homepage = "http://github.com/leonid-shevtsov/ruby-progressbar"
  s.summary = <<END
Ruby/ProgressBar is a text progress bar library for Ruby.
It can indicate progress with percentage, a progress bar,
and estimated remaining time.
END
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
