class NetEvaluator
  attr_accessor :net, :training_items, :eval_items, :high_error, :times, :silent

  def initialize(net, training_items, eval_items)
    @silent = false
    @net = net
    @training_items= training_items
    @eval_items = eval_items
    @last_error = nil
    @high_error = 0.0
    @times = nil
  end

  def puts(*args)
    super(*args) unless silent
  end

  def run
    @times = Benchmark.measure do
      train
      eval
    end
    puts "user time: #{times.utime}"
    puts "high_error: #{high_error}"
    {:utime => times.utime, :high_error => high_error}
  end

  def train
    100.times do |i|
      training_items.each do |item|
        @last_error = net.train(item.input, item.output)
        item.after_run({:error => @last_error, :output => net.activation_nodes.last.clone}) if item.respond_to?(:after_run)
      end
      puts "Error after propagation: #{i}:\t#{@last_error}" if i % 20 == 0
    end
  end

  def eval
    eval_items.each do |item|
      eval_item(item)
    end
  end

  def eval_item(item)
    outputs = net.eval(item.input)
    @last_error = net.send(:calculate_error, item.output)
    @high_error = @last_error if @last_error > @high_error
    item.after_run({:error => @last_error, :output => outputs}) if item.respond_to?(:after_run)
    {:outputs => outputs, :error => @last_error}
  end
end

