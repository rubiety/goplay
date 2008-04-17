module Go
  class Grid
    attr_accessor :matrix
    
    def initialize(size)
      @matrix = (1..size).inject([]) {|grid,row_index| grid << Array.new(size)}
    end
    
    def get(row, column)
      @matrix[row][column]
    end
    
    def set(row, column, value)
      @matrix[row][column] = value
    end
    
    def north_of(row, column); return row, column - 1; end
    def south_of(row, column); return row, column + 1; end
    def east_of(row, column); return row + 1, column; end
    def west_of(row, column); return row - 1, column; end
    def northeast_of(row, column); return row + 1, column - 1; end
    def northwest_of(row, column); return row - 1, column - 1; end
    def southeast_of(row, column); return row + 1, column + 1; end
    def southwest_of(row, column); return row - 1, column + 1; end
    
    def to_s
      
    end
    
    def to_a
      @matrix
    end
  end
end
