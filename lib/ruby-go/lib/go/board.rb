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
    attr_accessor :white_capture_count
    attr_accessor :black_capture_count
    
    def initialize(size)
      @size = size
      @grid = Grid.new(@size)
      @chains = ChainList.new(self)
      @enclosures = EnclosureList.new(self)
      @white_capture_count = 0
      @black_capture_count = 0
    end
    
    def capture_count_for(color)
      color == :white ? white_capture_count : black_capture_count
    end
    
    # Dumps Board State to Hash
    def to_hash
      {
        :grid => self.grid,
        :chains => self.chains,
        :enclosures => self.enclosures,
        :white_capture_count => self.white_capture_count,
        :black_capture_count => self.black_capture_count
      }
    end
    
    # Loads Board State from Hash
    def from_hash(value)
      self.grid = value[:grid] if value[:grid]
      self.chains = value[:chains] if value[:chains]
      self.enclosures = value[:enclosures] if value[:enclosures]
      self.white_capture_count = value[:white_capture_count] if value[:white_capture_count]
      self.black_capture_count = value[:black_capture_count] if value[:black_capture_count]
    end
    
    # Other Color
    def other_color(color)
      color == :white ? :black : :white
    end
    
    # String Representation
    def to_s
      self.grid.to_s
    end
  end
end
