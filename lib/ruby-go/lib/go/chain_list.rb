# == Chain List
# An extended array containing chains, with some utility methods.
#
module Go
  class ChainList < Array
    attr_accessor :board
    
    def initialize(board)
      super()
      self.board = board
    end
    
    def of_color(color)
      self.select {|c| c.color == color.to_sym }
    end
    def white; of_color(:white); end
    def black; of_color(:black); end
    
    def neighbors_of(color, row, column)
      board.grid.neighbors_of(row, column).map do |pair|
        find_by_position(color, pair[0], pair[1])
      end.compact.uniq
    end
    
    def add(color, row, column)
      chain = Chain.new(self, color, row, column)
      self << chain
      chain
    end
    
    def remove(chain)
      self.delete(chain)
      self
    end
    
    def find_by_position(color, row, column)
      self.of_color(color).detect {|c| c.contains_stone?(row, column)}
    end
  end
end
