class Board
  extend Forwardable
  
  attr_accessor :game
  
  def grid; @grid ||= create_square_matrix(game.board_size); end
  def grid=(value); @grid = value; end
  
  def_delegators :grid, :[]
  
  def initialize(game)
    @game = game
  end
  
  # Constructs the grid using move and capture information
  def reconstruct_grid_from_moves
    @game.moves.each do |move|
      color = (move.user == @game.white_player) ? 'W' : 'B'
      @grid[move.row][move.column] = color.to_sym
      
      move.captures.each do |capture|
        @grid[capture.row][capture.column] = (color + 'C').to_sym
      end
    end
    @grid
  end
  
  private
  
  # Create nil-defaulted 2-dimentional Array with some functional programming goodness...
  def create_square_matrix(size)
    size = 9
    (1..size).inject([]) {|grid,row_index| grid << Array.new(size)}
  end
  
end
