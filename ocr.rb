require_relative 'basic_image'
require_relative 'sample'
require_relative 'net_evaluator'

class ThreeShapes
  SHAPES = [
    {:letter => 's', :title => 'Square', :output => [1.0, 0.0, 0.0]},
    {:letter => 't', :title => 'Triangle', :output => [0.0, 1.0, 0.0]},
    {:letter => 'c', :title => 'Cross', :output => [0.0, 0.0, 1.0]}
  ].map { |s| Sample.new(s) }

  DISTORTED_CODES = ['wn', 'wbn']

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

  def training_items
    @training_items ||= ThreeShapes::SHAPES.map { |shape| ThreeShapes::ShapeTrainingData.new(shape) }
  end

  def eval_items
    @eval_items ||= begin
      ThreeShapes::SHAPES.map do |shape|
        ([nil] + ThreeShapes::DISTORTED_CODES).map do |distortion|
          eval_item = ThreeShapes::ShapeData.new(shape, distortion)
        end
      end.flatten
    end
  end
end

class OCR
  attr_accessor :net

  def initialize
    # Create the network with:
    #   4 inputs
    #   1 hidden layer with 3 neurons
    #   1 output
  end

  def net
    @net ||= begin
      srand 1
      layers = [BasicImage::INPUT_COUNT, BasicImage::INPUT_COUNT / 2, ThreeShapes::SHAPES.length]
      Ai4r::NeuralNetwork::Backpropagation.new(layers)
    end
  end

  def evaluator
    three_shapes = ThreeShapes.new
    @evaluator ||= NetEvaluator.new(net, three_shapes.training_items, three_shapes.eval_items)
  end

  def puts(*args)
    super(*args) unless silent
  end

  def run
    evaluator.run
  end
end

