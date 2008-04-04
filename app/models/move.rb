class Move < DataMapper::Base
  extend Forwardable
  
  property :game_id, :integer
  property :user_id, :integer
  property :index, :integer
  property :row, :integer
  property :column, :integer
  property :created_at, :datetime
  
  belongs_to :game
  belongs_to :user
  
  def_delegators :game, :board
  def_delegators :board, :grid
  
  has_many :captures
  
  after_create :spawn_event
  before_save :check_move
  before_save :update_board
  after_save :create_captures
  
  private
  
  def spawn_event
    MoveEvent.new(self).enqueue
    true
  end
  
  def check_move
    true
  end
  
  def update_board
    true
  end
  
  def create_captures
    true
  end
end
