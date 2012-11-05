require 'ai4r'
require 'RMagick'
require 'ostruct'

class OCR
  attr_accessor :net

  class Sample < OpenStruct
    def filename
      "data/#{letter}.png"
    end
  end

  SHAPES = [
    {:letter => 's', :title => 'Square', :output => [1.0, 0.0, 0.0]},
    {:letter => 't', :title => 'Triangle', :output => [0.0, 1.0, 0.0]},
    {:letter => 'c', :title => 'Cross', :output => [0.0, 0.0, 1.0]}
  ].map { |s| Sample.new(s) }

  DISTORTED_CODES = ['wn', 'wbn']
  IMAGE_WIDTH = 16
  IMAGE_HEIGHT = 16
  INPUTS_COUNT = IMAGE_WIDTH * IMAGE_HEIGHT

  def initialize
    # Create the network with:
    #   4 inputs
    #   1 hidden layer with 3 neurons
    #   1 output
    @net = Ai4r::NeuralNetwork::Backpropagation.new([INPUTS_COUNT, SHAPES.length])
  end

  def pixels_for_file(filename)
    @pixels ||= {}
    @pixels[filename] ||= begin
      image = Magick::ImageList.new(filename)
      image.get_pixels(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT)
    end
  end

  def shape_values(shape)
    file_shape_values(shape)
  end

  def format_values(values)
    values.each_slice(16).map do |row|
      row.join(", ")
    end.join("\n")
  end

  def file_shape_values(shape)
    pixels = pixels_for_file(shape.filename)
    pixels.map do |p|
      v = 1.0 - ((p.red + p.green + p.blue) / (3.0 * 65536))
      (v * 2.0).round(1)
    end
  end

  def run
    square = SHAPES.detect { |s| s.letter == 's' }
    triangle = SHAPES.detect { |s| s.letter == 't' }
    cross = SHAPES.detect { |s| s.letter == 'c' }

    # Train the network
    101.times do |i|
      error = net.train(shape_values(square), square.output)
      error = net.train(shape_values(triangle), triangle.output)
      error = net.train(shape_values(cross), cross.output)
      puts "Error after propagation: #{i}:\t#{error}" if i % 20 == 0
    end

    # Use it: Evaluate data with the trained network
    #p net.eval([10, 10, 0, 0])
    #p net.eval([10, 10, 10, 10])
    #p net.eval([0, 10, 10, 10])
  end
end

OCR.new.run

