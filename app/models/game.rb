# == Game
# Implements a game.  Each game has a +white_player+ and a +black_player+ 
# as well as an associated board size specified when creating the game 
# (as Go can be played with whatever board size you want).
# 
# === Game States
# In order to keep track of status as the game progresses,
# a basic status system is in place in which the status 
# field is expected to be updated to the following values in the 
# following order:
# 
# * Created
# * Invited
# * Accepted
# * In-Progress
# * Completed
# 
# When a game is completed, +completed_status+ may be one of three values:
# 
# * Win - game was a win, player determined by +white_won?+.
# * Draw - game was a draw with a tied store.
# * Cancelled - game was cancelled by a user leaving the game or logging 
#   out prematurely.
# 
# === Remote Event Spawning
# Remove +Event+ objects are spawned automatically through the +spawn_invite_event+ 
# callback.  
# 
# === Board State
# A two-dimentional array of board state is stored to avoid having to reconstruct 
# board state from moves on every request.  This array is stored in a YAML-serialized 
# field +board_state+.
# 
class Game < DataMapper::Base
  property :white_player_id, :integer
  property :black_player_id, :integer
  property :board_size, :integer
  property :board_state, :text
  property :status, :string   # Created => Accepted => In-Progress => Completed
  property :completed_status, :string  # Win, Draw, Cancelled
  property :white_won, :boolean
  property :created_at, :datetime
  property :updated_at, :datetime
  
  belongs_to :white_player, :class => 'User', :foreign_key => 'white_player_id'
  belongs_to :black_player, :class => 'User', :foreign_key => 'black_player_id'
  
  has_many :moves
  has_many :messages
  has_many :events
  
  after_create :spawn_invite_event
  before_save :encode_board_state
  after_save :decode_board_state
  
  # Constructs the game and sets the initial status to Created
  def initialize(*args)
    super
    self.status = 'Created'
  end
  
  # Wraps an associated instance of +Board+ through composition.
  def board
    @board ||= Board.new(self)
  end
  
  # Merb-special method used when constructing pretty URLs
  def to_param
    "#{id}-#{white_player.handle.downcase}-vs-#{black_player.handle.downcase}"
  end
  
  # User has accepted the invite, update status and set invite response event
  def accept!
    self.status = 'Accepted'
    self.save
    GameInviteResponseEvent.new(self).enqueue
  end
  
  # User has rejected the invite, update status and set invite response event
  def reject!
    self.status = 'Rejected'
    self.save
    GameInviteResponseEvent.new(self).enqueue
  end
  
  # Game is complete
  def complete!
    self.status = 'Complete'
  end
  
  # Determines the opponent given a "current_user"
  def opponent(current_user)
    return black_player if white_player == current_user
    return white_player if black_player == current_user
    nil
  end
  
  # Determines the color of the passed "current_user"
  def color(current_user)
    return :white if white_player == current_user
    return :black if black_player == current_user
    nil
  end
  
  # Makes a move on the board - effectively delegates to board
  def make_move(current_user, row, column)
    board.make_move(color(current_user), row, column)
  end
  
  private
  
  def spawn_invite_event
    GameInviteEvent.new(self).enqueue
    true
  end
  
  def encode_board_state
    self.board_state = YAML::dump(board.grid)
  end
  
  def decode_board_state
    board.grid = YAML::load(board_state) if board_state
  end
end
