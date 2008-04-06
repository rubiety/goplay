# == Remote Event
# Forms the model layer foundation to the remote events polling system 
# as described fully in +Events+.  
# 
# Acts as a base for single-table inheritance which occurs automatically 
# as part of DataMapper.  Most subclasses will define constructors that 
# set a hash-based "payload" which subsequently gets stored and retrieved 
# as a YAML-serialized field in the model.
# 
class Event < DataMapper::Base
  property :type, :class
  property :user_id, :integer
  property :source_user_id, :integer
  property :game_id, :integer
  property :payload_serialized, :text, :lazy => false
  property :created_at, :datetime
  property :consumed_at, :datetime
  
  attr_accessor :payload
  
  belongs_to :user
  belongs_to :source_user, :class => 'User', :foreign_key => 'source_user_id'
  belongs_to :game
  
  before_save :encode_payload
  after_materialize :decode_payload
  
  # Sets a blank payload; should be implemented by subclasses.
  def initialize
    self.payload = {}
    super
  end
  
  # Special method that will get called when the array of Event objects 
  # has +to_json+ called on it.  Returns a JSON representation of the event.
  def to_json
    {:type => type, :game_id => game ? game.id : nil, :payload => payload}.to_json
  end
  
  # Enqueues the event for eventual client polling
  def enqueue
    self.save
  end
  
  # Same as enqueue but spawns events for all active users
  def enqueue_for_all_active_users(options = {})
    events = []
    User.all(:active => true).each do |user|
      event = self.dup
      event.user_id = user.id
      event.save
      events << event
    end
    events
  end
  
  private
  
  def encode_payload
    self.payload_serialized = YAML::dump(payload)
  end
  
  def decode_payload
    self.payload = YAML::load(payload_serialized)
  end
  
end

