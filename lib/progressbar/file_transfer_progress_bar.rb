# Progress bar for file transfer. Assumes that +count+ and +total+ are measured in bytes.
#
# Displays transferred bytes and transfer rate.
class FileTransferProgressBar < ProgressBar
  def initialize(*args)
    super
    @format_arguments = [:title, :percentage, :bar, :stat_for_file_transfer]
  end

  protected

  def bytes
    convert_bytes(@current)
  end

  def fmt_stat_for_file_transfer
    if @finished then 
      sprintf("%s %s %s", bytes, transfer_rate, fmt_elapsed)
    else 
      sprintf("%s %s %s", bytes, transfer_rate, fmt_eta)
    end
  end

  def convert_bytes (bytes)
    if bytes < 1024
      sprintf("%6dB", bytes)
    elsif bytes < 1024 * 1000 # 1000kb
      sprintf("%5.1fKB", bytes.to_f / 1024)
    elsif bytes < 1024 * 1024 * 1000  # 1000mb
      sprintf("%5.1fMB", bytes.to_f / 1024 / 1024)
    else
      sprintf("%5.1fGB", bytes.to_f / 1024 / 1024 / 1024)
    end
  end

  def transfer_rate
    bytes_per_second = @current.to_f / (Time.now - @start_time)
    sprintf("%s/s", convert_bytes(bytes_per_second))
  end

end
