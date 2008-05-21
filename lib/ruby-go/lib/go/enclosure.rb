module Go
  class Enclosure
    attr_accessor :enclosure_list
    attr_accessor :spaces
    attr_accessor :liberties
    
    def initialize(enclosure_list, row, column)
      self.enclosure_list = enclosure_list
      self.liberties = []
      self.spaces = [[row, column]]
    end
    
    def contains_space?(row, column)
      self.spaces.include?([row, column])
    end
    
    def add_space(row, column)
      self.spaces << [row, column]
      recalculate_liberties!
    end
    
    # Should call this if manually adding to stones array for efficiency
    def spaces_updated!
      recalculate_liberties!
    end
    
    # Recalculates liberties
    def recalculate_liberties!
      self.liberties = []
      self.spaces.each do |row, column|
        self.liberties += self.enclosure_list.board.grid.occupied_neighbors_of(row, column)
      end
      self.liberties.uniq!
      self
    end
    
    # Graphical Board Representation
    def to_s
      self.enclosure_list.board.grid.matrix.map_with_index do |row, r|
        row.map_with_index do |column, c|
          if self.spaces.include?([r, c])
            ' E '
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
