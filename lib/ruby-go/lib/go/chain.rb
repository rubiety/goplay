# == Chain
# A "chain" in Go is a group of contiguous stones of the same color and 
# forms the basis of much of algorithmic Go play.  For each turn chains are 
# updated with stones and the liberty count is recalculated.  Once a chain 
# reaches a liberty count of zero, this signifies a capture.
# 
module Go
  class Chain
    attr_accessor :chain_list
    attr_accessor :color
    attr_accessor :origin_row
    attr_accessor :origin_column
    attr_accessor :stones
    attr_accessor :liberties
    attr_accessor :neighbors
    
    def initialize(chain_list, color, row, column)
      self.chain_list = chain_list
      self.color = color
      self.origin_row = row
      self.origin_column = column
      
      self.stones = [[row, column]]
      self.liberties = []
      self.neighbors = []
      self.stones_updated!
    end
    
    def contains_stone?(row, column)
      self.stones.include?([row, column])
    end
    
    def add_stone(row, column)
      self.stones << [row, column]
      stones_updated!
    end
    
    # Should call this if manually adding to stones array for efficiency
    def stones_updated!
      update_origin!
      recalculate_liberties!
    end
    
    # Origin should always be top left most stone in a string - ensure this.
    # TODO: Holding off on this for now, not sure why we need to do this...
    def update_origin!
      min_row = self.stones.map {|r, c| r }.min
      min_column = self.stones.map {|r, c| c }.min
      self.origin_row = min_row
      self.origin_column = min_column
      self
    end
    
    # Recalculates liberties
    def recalculate_liberties!
      self.liberties = []
      self.stones.each do |row, column|
        self.liberties += self.chain_list.board.grid.free_neighbors_of(row, column)
      end
      self.liberties.uniq!
      self
    end
    
    def to_s
      self.chain_list.board.grid.matrix.map_with_index do |row, r|
        row.map_with_index do |column, c|
          if self.stones.include?([r, c])
            {:black => ' B ', :white => ' W '}[color]
          elsif self.liberties.include?([r, c])
            ' L '
          else
            ' . '
          end
        end.join('')
      end.join("\n")
    end
    
  end
end
