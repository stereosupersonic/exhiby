class PerceptualHashCalculator < BaseService
  HASH_SIZE = 8
  RESIZE_SIZE = 32

  attr_reader :file_path

  def initialize(file_path)
    @file_path = file_path
  end

  def call
    path = file_path.to_s
    return nil unless File.exist?(path)

    image = load_and_prepare_image(path)
    return nil if image.nil?

    dct_result = apply_dct(image)
    generate_hash(dct_result)
  rescue StandardError => e
    Rails.logger.error("PerceptualHashCalculator failed for #{file_path}: #{e.message}")
    nil
  end

  private

  def load_and_prepare_image(path)
    image = Vips::Image.new_from_file(path, access: :sequential)
    image = image.colourspace(:b_w) if image.bands > 1

    image = image.thumbnail_image(RESIZE_SIZE, height: RESIZE_SIZE, size: :force)
    image.gravity(:centre, RESIZE_SIZE, RESIZE_SIZE)
  rescue Vips::Error => e
    Rails.logger.warn("Failed to load image #{path}: #{e.message}")
    nil
  end

  def apply_dct(image)
    pixels = image.to_a.flatten.map(&:to_f)

    dct_matrix = compute_dct_2d(pixels, RESIZE_SIZE)
    extract_low_frequencies(dct_matrix)
  end

  def compute_dct_2d(pixels, size)
    result = Array.new(size) { Array.new(size, 0.0) }

    size.times do |u|
      size.times do |v|
        sum = 0.0
        size.times do |x|
          size.times do |y|
            pixel_value = pixels[x * size + y]
            sum += pixel_value *
              Math.cos(((2 * x + 1) * u * Math::PI) / (2 * size)) *
              Math.cos(((2 * y + 1) * v * Math::PI) / (2 * size))
          end
        end

        alpha_u = u.zero? ? 1.0 / Math.sqrt(size) : Math.sqrt(2.0 / size)
        alpha_v = v.zero? ? 1.0 / Math.sqrt(size) : Math.sqrt(2.0 / size)
        result[u][v] = alpha_u * alpha_v * sum
      end
    end

    result
  end

  def extract_low_frequencies(dct_matrix)
    low_freq = []
    HASH_SIZE.times do |i|
      HASH_SIZE.times do |j|
        low_freq << dct_matrix[i][j] unless i.zero? && j.zero?
      end
    end
    low_freq
  end

  def generate_hash(dct_values)
    median = calculate_median(dct_values)

    bits = dct_values.map { |v| v > median ? 1 : 0 }

    hash_value = bits.each_slice(4).map do |nibble|
      nibble.join.to_i(2).to_s(16)
    end.join

    hash_value.ljust(16, "0")[0, 16]
  end

  def calculate_median(values)
    sorted = values.sort
    mid = sorted.length / 2

    if sorted.length.odd?
      sorted[mid]
    else
      (sorted[mid - 1] + sorted[mid]) / 2.0
    end
  end
end
