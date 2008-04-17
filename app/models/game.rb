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
  property :board_state, :text, :lazy => false
  property :whites_turn, :boolean, :default => false
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
  after_materialize :decode_board_state
  
  # Constructs the game and sets the initial status to Created
  def initialize(*args)
    super
    
    self.status = 'Created'
  end
  
  def board
    @board ||= Go::Board.new(self.board_size.to_i)
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
  
  # Game was cancelled by a user leaving/forfeiting
  def cancel!
    self.status = 'Complete'
    self.completed_status = 'Cancelled'
  end
  
  # Determines the opponent given a "current_user"
  def opponent_of(current_user)
    return black_player if white_player == current_user
    return white_player if black_player == current_user
    nil
  end
  
  # Determines the color of the passed "current_user"
  def color_of(current_user)
    return :white if white_player == current_user
    return :black if black_player == current_user
    nil
  end
  
  # Determines the player of a particular color
  def player_of_color(color)
    return white_player if color.to_sym == :white
    return black_player if color.to_sym == :black
    nil
  end
  
  # Determines if it is currently the given player's turn
  def players_turn?(current_user)
    (white_player == current_user && whites_turn) || (black_player == current_user && !whites_turn)
  end
  
  # Makes a move on the board - effectively delegates to board
  def make_move(current_user, row, column)
    board.make_move(color_of(current_user), row, column)
  end
  
  # Provides JSON representation of game
  def to_json(for_player = nil)
    if for_player
      {
        :game => self.to_hash, 
        :user => for_player.to_hash, 
        :opponent => (self.opponent_of(for_player) || {}).to_hash.merge(:color => self.color_of(self.opponent_of(for_player))),
        :color => self.color_of(for_player),
        :my_turn => players_turn?(for_player)
      }.to_json
    else
      self.to_hash.to_json
    end
  end
  
  def to_hash
    {
      :white_player_id => white_player_id,
      :black_player_id => black_player_id,
      :board_size => board_size,
      :grid => board.grid.to_a,
      :current_turn => whites_turn ? :white : :black
    }
  end
  
  private
  
  def spawn_invite_event
    GameInviteEvent.new(self).enqueue
    true
  end
  
  def encode_board_state
    self.board_state = YAML::dump(board.to_hash)
  end
  
  def decode_board_state
    return true unless board_state
    board.from_hash(YAML::load(board_state))
  end
end
