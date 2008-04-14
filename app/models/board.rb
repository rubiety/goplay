# == Game Board
# Represents a Go game board and implements all of the rules 
# of go as well as maintains the state of the board as the game 
# progresses.  This state is seralized and deserialized into the 
# database for quick processing.
# 
# This class is somewhat coupled to +Game+ but I decided to use 
# composition rather than just bloating up the Game class with 
# excess Go-specific logic.
# 
class Board
  
  module Errors
    # Generic Invalid Move Error
    class InvalidMoveError < StandardError; end

    # Raised when the move target exists
    class MoveTargetExistsError < InvalidMoveError; end

    # The "Rule of Ko" in Go is implemented to prevent repetitive situations 
    # from arising in certain circumstances.
    class RuleOfKoError < InvalidMoveError; end

    # A suicidal move, or one that will result in that stone being immediately 
    # captured, is not allowed.
    class SuicidalMoveError < InvalidMoveError; end
  end
  
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
  end
  
  class StoneStringList < Array
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
  
  class StoneString
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
  
  
  
  attr_accessor :game
  
  def initialize(game)
    @game = game
  end
  
  def grid
    @grid ||= Grid.new(game.board_size)
  end
  
  def grid=(value)
    @grid = value
  end
  
  def strings
    @strings ||= StoneStringList.new
  end
  
  def strings=(value)
    @strings = value
  end
  
  # Makes a Move and returns an array of captures resulting from the move in tuple form
  def make_move(color, row, column)
    raise Errors::MoveTargetExistsError.new unless grid[row][column].nil?
    raise Errors::RuleOfKoError.new if rule_of_ko_move?(color, row, column)
    raise Errors::SuicidalMoveError.new if suicidal_move?(color, row, column)
    
    add_stone(color, row, column)
    compute_move_captures(color, row, column)
  end
  
  def add_stone(color, row, column)
    # Add to Grid:
    grid[row][column] = color
    
    # Update Stone String List
    update_string_list_with(color, row, column)
  end
  
  # If 1. The stone is isolated - no friendly neighbor
  #   Create new string
  # 
  # If 2. Stone has exactly one friendly neighbor
  #   Append to neighbor's string and recalc liberties
  # 
  # If 3. Stone has at least two friendly neighbors
  #  A. If all neighbors are members of the same string, append to string.
  #  B. If neighbors are in different strings, join strings together and append to new string.
  # 
  def update_string_list_with(color, row, column)
    
  end
  
  # Compute Move Captures
  # 1. If there are any adjacent opponent strings without liberties, remove them and increase the prisoner count.
  # 2. If the newly placed stone is part of a string without liberties, remove it and increase the prisoner count.
  def compute_move_captures(color, row, column)
    
  end
  
  
  
  # Detects a "Rule of Ko" situation, which is not allowed
  def rule_of_ko_move(color, row, column)
    false
  end
  
  # Detects a "Suicidal Move" situation, which is not allowed.
  # This is the case if
  # 1. There is no neighboring empty intersection.
  # 2. There is no neighboring opponent string with exactly one liberty.
  # 3. There is no neighboring friendly string with more than one liberty.
  def suicidal_move?(color, row, column)
    false
  end
  
  # Compute Scores - intended for the end of a game
  def compute_scores
    false
  end
  
end
