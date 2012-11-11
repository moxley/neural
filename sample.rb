class Sample < OpenStruct
  def filename(distortion = nil)
    if distortion
      "data/#{letter}_#{distortion}.png"
    else
      "data/#{letter}.png"
    end
  end
end

