require_relative 'basic_image'
require_relative 'sample'
require_relative 'net_evaluator'

class OCR
  attr_accessor :net, :silent

  SHAPES = [
    {:letter => 's', :title => 'Square', :output => [1.0, 0.0, 0.0]},
    {:letter => 't', :title => 'Triangle', :output => [0.0, 1.0, 0.0]},
    {:letter => 'c', :title => 'Cross', :output => [0.0, 0.0, 1.0]}
  ].map { |s| Sample.new(s) }

  DISTORTED_CODES = ['wn', 'wbn']

  def initialize
    @silent = false
    # Create the network with:
    #   4 inputs
    #   1 hidden layer with 3 neurons
    #   1 output
    srand 1
    @net = Ai4r::NeuralNetwork::Backpropagation.new([BasicImage::INPUT_COUNT, BasicImage::INPUT_COUNT / 2, SHAPES.length])
  end

  class ShapeData
    attr_accessor :shape

    def initialize(shape, distortion = nil)
      @shape = shape
      @distortion = distortion
    end

    def input
      image_util.shape_values(@shape, @distortion)
    end

    def image_util
      @image_util ||= BasicImage.new
    end

    def output
      @shape.output
    end

    def after_run(error)
      filename = shape.filename(@distortion)
      puts "#{filename}: #{error}"
    end
  end

  class ShapeTrainingData < ShapeData
    def after_run(error)
      # Do nothing
    end
  end

  def evaluator
    @evaluator ||= begin
      # net, training_items, eval_items
      training_items = SHAPES.map { |shape| ShapeTrainingData.new(shape) }
      eval_items = SHAPES.map do |shape|
        ([nil] + DISTORTED_CODES).map do |distortion|
          eval_item = ShapeData.new(shape, distortion)
        end
      end.flatten
      NetEvaluator.new(@net, training_items, eval_items)
    end
  end

  def puts(*args)
    super(*args) unless silent
  end

  def run
    evaluator.run
    puts "user time: #{evaluator.times.utime}"
    puts "high_error: #{evaluator.high_error}"
    {:utime => evaluator.times.utime, :high_error => evaluator.high_error}
  end
end

