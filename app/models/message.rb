# == Chat Message
# Represents a chat message sent either globally, 
# in which case +game_id+ is NULL, or to a specific game in which 
# +game_id+ is populated.  
# 
# === Event Spawning
# The remote events that broadcast the event to the target user(s) 
# are handled automatically through the +spawn_event+ after_create callback.
# 
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
    if self.game
      event.enqueue_for_all_active_users(:only => [self.game.white_player.id, self.game.black_player.id])
    else
      event.enqueue_for_all_active_users
    end
    true
  end
end
