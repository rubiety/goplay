class Game < DataMapper::Base
  extend Forwardable
  
  property :white_player_id, :integer
  property :black_player_id, :integer
  property :board_size, :integer
  property :board_state, :text
  property :status, :string   # Created => Invited => Accepted => In-Progress => Completed
  property :completed_status, :string  # Win, Draw, Left
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
  
  def initialize(*args)
    super
    self.status = 'Created'
  end
  
  def board
    @board ||= Board.new(self)
  end
  
  def accept
    self.status = 'Accepted'
    self.save
    GameInviteResponseEvent.new(self).enqueue
  end
  
  def reject
    self.status = 'Rejected'
    self.save
    GameInviteResponseEvent.new(self).enqueue
  end
  
  def complete
    self.status = 'Complete'
  end
  
  def to_param
    "#{id}-#{white_player.handle.downcase}-vs-#{black_player.handle.downcase}"
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
