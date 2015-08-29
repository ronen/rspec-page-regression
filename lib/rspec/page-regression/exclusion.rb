module RSpec::PageRegression
  class Exclusion
    def initialize hsh
      @left = hsh[:left]
      @top = hsh[:top]
      @right = hsh[:right]
      @bottom = hsh[:bottom]
    end

    def row? y
      return false unless @left == 0 && @right == -1
      y >= @top && (y <= @bottom || @bottom == -1)
    end

    def point? x, y
      row = y >= @top && y <= @bottom
      col = x >= @left && x <= @right
      row?(y) || (row && col)
    end
  end
end
