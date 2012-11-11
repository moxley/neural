class BasicImage
  IMAGE_WIDTH = 16
  IMAGE_HEIGHT = 16
  INPUT_COUNT = IMAGE_WIDTH * IMAGE_HEIGHT

  def pixels_for_file(filename)
    @pixels ||= {}
    @pixels[filename] ||= begin
      image = Magick::ImageList.new(filename)
      image.get_pixels(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT)
    end
  end

  def format_input(values)
    input.each_slice(IMAGE_WIDTH).map { |row| row.map(&:to_i).join(" ") }.join("\n")
  end

  def convert_file_pixels(pixels)
    pixels.map do |p|
      v = 1.0 - ((p.red + p.green + p.blue) / (3.0 * 65536))
      (v * 2.0).round(1)
    end
  end

  def shape_values(shape, distortion = nil)
    convert_file_pixels(pixels_for_file(shape.filename(distortion)))
  end
end

