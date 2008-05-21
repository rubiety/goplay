# == Enclosure List
# An extended array containing enclosures, with some utility methods.
#
module Go
  class EnclosureList < Array
    attr_accessor :board
    
    def initialize(board)
      super()
      self.board = board
    end
    
    def neighbors_of(row, column)
      board.grid.neighbors_of(row, column).map do |r, c|
        find_by_position(r, c)
      end.compact.uniq
    end
    
    def add(row, column)
      enclosure = Enclosure.new(self, row, column)
      self << enclosure
      enclosure
    end
    
    def remove(enclosure)
      self.delete(enclosure)
      self
    end
    
    def find_by_position(row, column)
      self.detect {|e| e.contains_space?(row, column)}
    end
  end
end
