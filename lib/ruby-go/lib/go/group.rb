module Go
  class GroupList < Array
    def self.find_by_position(color, row, column)
      
    end
    
    def self.find_or_create_by_position(color, row, column)
      find_by_position(row, column) || create(color, row, column)
    end
    
    def self.create(color, row, column)
      stone_string = StoneString.new(color, row, column)
      self << stone_string
      stone_string
    end
  end
  
  class Group
    attr_accessor :color
    attr_accessor :origin_row
    attr_accessor :origin_column
    attr_accessor :liberties
    attr_accessor :neighbors
    
    def initialize(color, row, column)
      self.color = color
      self.origin_row = row
      self.origin_column = column
      
      self.liberties = []
      self.neighbors = []
    end
    
    # Origin should always be top left most stone in a string - ensure this.
    def update_origin!
      
    end
    
    # Recalculates liberties
    def recalculate_liberties!
      
    end
  end
end