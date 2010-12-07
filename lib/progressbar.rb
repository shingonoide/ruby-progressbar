# Ruby/ProgressBar - a text progress bar library
#
# Copyright (C) 2001-2005 Satoru Takabayashi <satoru@namazu.org>
#     All rights reserved.
#     This is free software with ABSOLUTELY NO WARRANTY.
#
# You can redistribute it and/or modify it under the terms
# of Ruby's license.
require 'progressbar/display_width_reader'
require 'progressbar/reversed_progress_bar'
require 'progressbar/file_transfer_progress_bar'
require 'progressbar/enumerable'

# Ruby/ProgressBar is a text progress bar library for Ruby.
#
# It can indicate progress with percentage, a progress bar,
# and estimated remaining time.
#
# == Examples
#
# Basic functionality:
#
#   % irb --simple-prompt -r progressbar
#   >> pbar = ProgressBar.new("test", 100)
#   => (ProgressBar: 0/100)
#   >> 100.times {sleep(0.1); pbar.inc}; pbar.finish
#   test:          100% |oooooooooooooooooooooooooooooooooooooooo| Time: 00:00:10
#   => nil
#
# Set position directly:
#
#   >> pbar = ProgressBar.new("test", 100)
#   => (ProgressBar: 0/100)
#   >> (1..100).each{|x| sleep(0.1); pbar.set(x)}; pbar.finish
#   test:           67% |oooooooooooooooooooooooooo              | ETA:  00:00:03
#
# Block mode:
#
#   >> ProgressBar.block('test',100) do |pbar|
#   >>   100.times { sleep(0.1); pbar.inc }
#   >> end
#
# Even simpler:
#
#   >> (1..100).to_a.each_with_progressbar('test') do
#   >>   sleep 0.1
#   >> end
class ProgressBar
  include DisplayWidthReader

  VERSION = "0.10"

  # Display the initial progress bar and return a
  # ProgressBar object. +title+ specifies the title,
  # and +total+ specifies the total cost of processing.
  # Optional parameter +out+ specifies the output IO.

  # The display of the progress bar is updated when one or
  # more percent is proceeded or one or more seconds are
  # elapsed from the previous display.
  def initialize (title, total, out = STDERR)
    @title = title
    @total = total
    @out = out
    @terminal_width = 80
    @bar_mark = "o"
    @current = 0
    @previous = 0
    @current_percentage = 0
    @finished = false
    @start_time = Time.now
    @previous_time = @start_time
    @title_width = [14, title.length+1].max
    @format = "%-#{@title_width}s %3d%% %s %s"
    @format_arguments = [:title, :percentage, :bar, :stat]
    clear
    show
  end

  # Progress bar title
  attr_reader   :title

  # Current position (integer)
  attr_reader   :current

  # Total count (maximum value of #current)
  attr_reader   :total

  # Time when the progress bar was started
  attr_accessor :start_time

  # Character used to fill up the progress bar. Default: +o+
  attr_writer   :bar_mark
  
  # Format for displaying a progress bar.
  # Default: <tt>"%-14s %3d%% %s %s"</tt>.
  attr_accessor :format

  # +fmt+ methods that get passsed to the format string.
  # Default: <tt>[:title, :percentage, :bar, :stat]</tt>
  attr_accessor :format_arguments
  
  # The current completion percentage, from 0 to 100
  attr_reader :current_percentage

  # Returns true if the progress bar is at 100%
  attr_reader :finished
  alias_method :finished?, :finished
  
  # Estimated Time of Arrival - time in seconds remaining until the progress bar reaches finish.
  def eta
    if @current == 0
      nil
    else
      elapsed = Time.now - @start_time
      eta = elapsed * @total / @current - elapsed;
    end
  end

  # Clears the progress bar display
  def clear
    @out.print "\r"
    @out.print(" " * (get_width - 1))
    @out.print "\r"
  end

  # Set progress at 100% then #halt
  def finish
    @current = @total
    halt
  end



  # Stop the progress bar and update the display of progress
  # bar. Display the elapsed time on the right side of the bar.
  def halt
    @finished = true
    update_position
    show
  end

  # Increase the internal counter by +step+ and update
  # the display of the progress bar. Display the estimated
  # remaining time on the right side of the bar. The counter
  # does not go beyond the +total+.
  def inc (step = 1)
    raise RuntimeError.new 'Progress bar already finished' if finished?
    @current += step
    @current = @total if @current > @total
    update_position
    show_if_needed
    @previous = @current
  end

  # Set the internal counter to +count+ and update the
  # display of the progress bar. Display the estimated
  # remaining time on the right side of the bar.  Raise if
  # +count+ is a negative number or a number more than
  # the +total+.
  def set (count)
    raise RuntimeError.new 'Progress bar already finished' if finished?
    if count < 0 || count > @total
      raise RuntimeError.new "invalid count: #{count} (total: #{@total})"
    end
    @current = count
    update_position
    show_if_needed
    @previous = @current
  end

  def inspect
    "#<#{self.class.to_s}:#{@current}/#{@total}>"
  end
  
  # Block mode; accepts same parameters as #new, yields with the ProgressBar instance
  def self.block(*args)
    pbar = ProgressBar.new(*args)
    yield pbar
    pbar.finish
  end

  protected
  
  def fmt_eta
    if eta.nil?
      "ETA:  --:--:--"
    else
      sprintf("ETA:  %s", format_time(eta))
    end
  end

  def fmt_bar
    bar_width = current_percentage * @terminal_width / 100
    sprintf("|%s%s|", @bar_mark * bar_width, " " *  (@terminal_width - bar_width))
  end

  def fmt_percentage
    current_percentage.to_s
  end

  def fmt_stat
    finished? ? fmt_elapsed : fmt_eta
  end

  def fmt_title
    @title[0,(@title_width - 1)] + ":"
  end

  def format_time (t)
    t = t.to_i
    sec = t % 60
    min  = (t / 60) % 60
    hour = t / 3600
    sprintf("%02d:%02d:%02d", hour, min, sec)
  end


  def fmt_elapsed
    elapsed = Time.now - @start_time
    sprintf("Time: %s", format_time(elapsed))
  end
  
  def eol
    if @finished then "\n" else "\r" end
  end

  def show
    arguments = @format_arguments.map {|method| 
      method = sprintf("fmt_%s", method)
      send(method)
    }
    line = sprintf(@format, *arguments)

    width = get_width
    if line.length == width - 1 
      @out.print(line + eol)
      @out.flush
    elsif line.length >= width
      @terminal_width = [@terminal_width - (line.length - width + 1), 0].max
      if @terminal_width == 0 then @out.print(line + eol) else show end
    else # line.length < width - 1
      @terminal_width += width - line.length + 1
      show
    end
    @previous_time = Time.now
  end

  def update_position
    if @total.zero?
      @current_percentage = 100
      @previous_percentage = 0
    else
      @current_percentage  = (@current  * 100 / @total).to_i
      @previous_percentage = (@previous * 100 / @total).to_i
    end
  end

  def show_if_needed
    # Use "!=" instead of ">" to support negative changes
    if @current_percentage != @previous_percentage || Time.now - @previous_time >= 1 || @finished
      show
    end
  end  
end
