# The functionality is identical to ProgressBar but the direction
# of the progress bar is just opposite.
class ReversedProgressBar < ProgressBar
  protected

  def do_percentage
    100 - super
  end
end
