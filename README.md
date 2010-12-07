# ruby/progressbar

Ruby/ProgressBar is a text progress bar library for Ruby.

It can indicate progress with percentage, a progress bar, and estimated remaining time.

## Examples

Basic functionality:

    % irb --simple-prompt -r progressbar
    >> pbar = ProgressBar.new("test", 100)
    => (ProgressBar: 0/100)
    >> 100.times {sleep(0.1); pbar.inc}; pbar.finish
    test:          100% |oooooooooooooooooooooooooooooooooooooooo| Time: 00:00:10
    => nil

Set position directly:

    >> pbar = ProgressBar.new("test", 100)
    => (ProgressBar: 0/100)
    >> (1..100).each{|x| sleep(0.1); pbar.set(x)}; pbar.finish
    test:           67% |oooooooooooooooooooooooooo              | ETA:  00:00:03

Block mode:

    >> ProgressBar.block('test',100) do |pbar|
    >>   100.times { sleep(0.1); pbar.inc }
    >> end

Even simpler:

    >> (1..100).to_a.each_with_progressbar('test') do
    >>   sleep 0.1
    >> end

## Installation

    gem install ruby-progressbar

## Limitations

Since the progress is calculated by the proportion to the 
total cost of processing, Ruby/ProgressBar cannot be used if
the total cost of processing is unknown in advance.
Moreover, the estimation of remaining time cannot be
accurately performed if the progress does not flow uniformly.

---

[Satoru Takabayashi](http://namazu.org/~satoru/)

Cleaned up by [Leonid Shevtsov](http://leonid.shevtsov.me)
