require "oily_png"

module RSpec::PageRegression

  class ImageComparison
    include ChunkyPNG::Color

    attr_reader :result

    def initialize(filepaths, ignores = nil)
      @filepaths = filepaths
      if ignores && ignores.flatten.length == 4
        @exclusions = [Exclusion.new(ignores)]
      elsif ignores && ignores.flatten.length > 4
        @exclusions = ignores.map {|i| Exclusion.new i}
      else
        @exclusions = []
      end
      @result = compare
    end

    def expected_size
      [@iexpected.width , @iexpected.height]
    end

    def test_size
      [@itest.width , @itest.height]
    end

    private

    def compare
      @filepaths.difference_image.unlink if @filepaths.difference_image.exist?

      return :missing_expected unless @filepaths.expected_image.exist?
      return :missing_test unless @filepaths.test_image.exist?

      @iexpected = ChunkyPNG::Image.from_file(@filepaths.expected_image)
      @itest = ChunkyPNG::Image.from_file(@filepaths.test_image)

      return :size_mismatch if test_size != expected_size

      max_count = RSpec::PageRegression.threshold * @itest.width * @itest.height
      count = different_pixels(max_count)
      return :match if count > RSpec::PageRegression.threshold * @itest.width * @itest.height

      create_difference_image
      return :difference
    end

    def different_pixels(max)
      count = 0
      @itest.height.times do |y|
        next if @itest.row(y) == @iexpected.row(y) || @exclusions.any?{|e| e.row? y}
        diff = @itest.row(y).zip(@iexpected.row(y)).select { |x, y| x != y && !excludes?(x,y) }
        count += diff.count
        return count if count > max
      end
      return count
    end

    def create_difference_image
      idiff = ChunkyPNG::Image.from_file(@filepaths.expected_image)
      xmin = @itest.width + 1
      xmax = -1
      ymin = @itest.height + 1
      ymax = -1
      @itest.height.times do |y|
        @itest.row(y).each_with_index do |test_pixel, x|
          if excludes? x, y
            val = rgb(0, 255, 0)
          elsif test_pixel != (expected_pixel = idiff[x,y])
            xmin = x if x < xmin
            xmax = x if x > xmax
            ymin = y if y < ymin
            ymax = y if y > ymax
            val = rgb(
              (r(test_pixel) - r(expected_pixel)).abs,
              (g(test_pixel) - g(expected_pixel)).abs,
              (b(test_pixel) - b(expected_pixel)).abs
            )
          else
            val = rgb(0,0,0)
          end
          idiff[x,y] = val
        end
      end

      idiff.rect(xmin-1,ymin-1,xmax+1,ymax+1,rgb(255,0,0))

      idiff.save @filepaths.difference_image
    end

    def excludes? x, y
      @exclusions.any?{|e| e.point? x, y}
    end
  end
end
