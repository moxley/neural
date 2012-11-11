class Comparisons
  def trials
    @trials ||= []
  end

  def add(&block)
    trials << block
  end

  def run
    trials.each do |trial|
      res = trial.call
    end
  end
end

