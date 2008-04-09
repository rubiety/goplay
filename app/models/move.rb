# == Game Move
# Represents a single move by a user in a game.  Stores
# coordinates of the move in +row+ and +column+ fields.  Related 
# to a move is the concept of a +Capture+. 
# 
# === Move Logic
# Actual game logic of move handling is handled by the +Board+ class
# of which +Game+ is a composition.  Handling of this is invoked through 
# a after_create callback which tries to make the move on the board and 
# creates the necessary related +Capture+ objects.
# 
# === Remote Event Spawning
# A remote move event is spawned automatically by the +spawn_event+ 
# after_create callback.
# 
class Move < DataMapper::Base
  property :game_id, :integer
  property :user_id, :integer
  property :index, :integer
  property :row, :integer
  property :column, :integer
  property :created_at, :datetime
  
  belongs_to :game
  belongs_to :user
  has_many :captures
  
  before_create :make_move
  after_create :update_game
  after_create :spawn_event
  
  private
  
  # Actually attemps to make the move on the game board
  def make_move
    computed_captures = game.make_move(user, row.to_i, column.to_i)
    computed_captures.each do |computed_capture|
      captures << Capture.new(:row => computed_capture[0], :column => computed_capture[1])
    end
    
    game.whites_turn = !self.game.whites_turn;
    
    true
  end
  
  def update_game
    game.save
  end
  
  def spawn_event
    MoveEvent.new(self).enqueue
    true
  end
end
