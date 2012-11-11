require 'ai4r'
require 'RMagick'
require 'ostruct'
require 'benchmark'

require_relative 'ocr'
require_relative 'trial'
require_relative 'comparisons'

comp = Comparisons.new

comp.add do
  Trial.new.run(1) do |ocr|
    #ocr.net = Ai4r::NeuralNetwork::Backpropagation.new([OCR::INPUTS_COUNT, OCR::INPUTS_COUNT / 2, OCR::SHAPES.length])
    ocr.net = Ai4r::NeuralNetwork::Backpropagation.new([BasicImage::INPUT_COUNT, OCR::SHAPES.length])
    ocr.silent = false
    ocr
  end.map { |res| puts "Trial res: #{res}" }
end

#comp.add do
#  res = Trial.new.run(5) do |ocr|
#    ocr.net = Ai4r::NeuralNetwork::Backpropagation.new([OCR::INPUTS_COUNT, OCR::INPUTS_COUNT / 3, OCR::SHAPES.length])
#    #ocr.silent = false
#    ocr
#  end
#
#  puts "Trial res: #{res}"
#  res
#end

comp.run

