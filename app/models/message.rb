class Message < DataMapper::Base
  property :game_id, :integer
  property :user_id, :integer
  property :message, :text, :lazy => false
  property :created_at, :datetime
  
  after_create :spawn_event
  
  belongs_to :game
  belongs_to :user
  
  
  private
  
  def spawn_event
    event = MessageEvent.new(self)
    self.game ? event.enqueue : event.enqueue_for_all_active_users
    true
  end
end
