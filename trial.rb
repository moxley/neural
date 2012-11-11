class Trial
  def run(repeat_count = 10, &block)
    time_sum = 0.0
    error_sum = 0.0
    repeat_count.times do
      o = OCR.new
      o.silent = true
      o = yield o if block
      res = o.run
      time_sum += res[:utime]
      error_sum += res[:high_error]
    end

    {:average_time       => time_sum / repeat_count,
     :average_high_error => error_sum / repeat_count}
  end
end

