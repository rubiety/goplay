# == Game Board
# Represents a Go game board and implements all of the rules 
# of go as well as maintains the state of the board as the game 
# progresses.  This state is seralized and deserialized into the 
# database for quick processing.
# 
module Go
  class Board
    attr_accessor :size
    attr_accessor :grid
    attr_accessor :chains
    attr_accessor :enclosures
    
    def initialize(size)
      @size = size
      @grid = Grid.new(@size)
      @chains = ChainList.new(self)
    end
    
    # Dumps Board State to Hash
    def to_hash
      {
        :grid => self.grid,
        :chains => self.chains,
        :enclosures => self.enclosures
      }
    end
    
    # Loads Board State from Hash
    def from_hash(value)
      self.grid = value[:grid] if value[:grid]
      self.chains = value[:chains] if value[:chains]
    end
    
    # String Representation
    def to_s
      self.grid.to_s
    end
  end
end
