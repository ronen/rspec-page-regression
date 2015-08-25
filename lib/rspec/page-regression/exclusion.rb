module RSpec::PageRegression
  class Exclusion
    def initialize arr
      @left = arr[0]
      @top = arr[1]
      @right = arr[2]
      @bottom = arr[3]
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
