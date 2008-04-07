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
  
  attr_accessor :game
  
  def initialize(game)
    @game = game
  end
  
  def grid
    @grid ||= create_square_matrix(game.board_size)
  end
  
  def grid=(value)
    @grid = value
  end
  
  # Constructs the grid using move and capture information
  def reconstruct_grid_from_moves
    @game.moves.each do |move|
      grid[move.row][move.column] = game.color(move.user)
      
      move.captures.each do |capture|
        grid[capture.row][capture.column] = nil
      end
    end
    grid
  end
  
  # Makes a Move and returns an array of captures resulting from the move in tuple form
  def make_move(color, row, column)
    raise MoveTargetExistsError.new unless grid[row][column].nil?
    raise RuleOfKoError.new if detect_rule_of_ko_situation(color, row, column)
    raise SuicidalMoveError.new if detect_suicidal_move_situation(color, row, column)
    
    grid[row][column] = color
    compute_move_captures(color, row, column)
  end
  
  private
  
  # Create nil-defaulted 2-dimentional Array with some functional programming goodness...
  def create_square_matrix(size)
    size = 9
    (1..size).inject([]) {|grid,row_index| grid << Array.new(size)}
  end
  
  # Detects a "Rule of Ko" situation, which is not allowed
  def detect_rule_of_ko_situation(color, row, column)
    false
  end
  
  # Detects a "Suicidal Move" situation, which is not allowed
  def detect_suicidal_move_situation(color, row, column)
    false
  end
  
  # Compute Move Captures
  def compute_move_captures(color, row, column)
    []
  end
  
  # Compute Scores - intended for the end of a game
  def compute_scores
    false
  end
  
end
