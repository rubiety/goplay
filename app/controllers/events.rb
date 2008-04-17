# == Remote Event Polling Responder
# Mean to be invoked in the REST context of a user, 
# this controller handles requests for remove JSON 
# event objects from the controller. 
# 
# Note that unlike common REST practices, for efficiency 
# of the remote events model, a GET on index actually 
# changes the state of the system (sets the consumed_at timestamp).
# 
# === How It Works
# * +Event+ instances are created on the server side from the 
#   many subclasses of Event (using automatic single-table inheritance).
#   Usually this is done transparently by callbacks on regular model classes
#   and does not need to be done explicitly by the controller.  Event subclass
#   of event will define a constructor that takes some data (typically a model object)
#   and constructs a hash-based "payload" for that event.  See more about this in 
#   +Event+.
# 
# * The JavaScript client does an Ajax get request on +Events#index+ to "consume"
#   the events.  What's returned will be an array of +Event+ objects represented 
#   in JSON.  The client can then pass these off to event handlers and deal with them
#   as appropriate, using the payload data.  
# 
# * When the client requests the events, each event is marked as "consumed" by setting
#   the +consumed_at+ timestamp.  Events that are consumed will not appear in future 
#   requests for +Events#index+.
# 
class Events < Application
  provides :xml, :yaml, :js
  
  before :login_required
  before :fetch_unconsumed_events, :only => [:index]
  
  # GET /users/current/events
  def index
    @events.each {|e| e.consumed_at = Time.now; e.save }
    current_user.pinged!
    
    User.sweep_stale_users!
    
    display @events
  end
  
  
  private
  
  def fetch_game
    @game = Game[params[:game_id]] if params[:game_id]
    @game = nil if @game and !@game.player?(@user)
  end
  
  def fetch_user
    @user = current_user
    raise NotFound unless @user
  end
  
  def fetch_unconsumed_events
    fetch_user
    fetch_game
    
    @events = if @game
      Event.all(:user_id => current_user.id, :game_id => @game.id, :consumed_at => nil)
    else
      Event.all(:user_id => current_user.id, :game_id => nil, :consumed_at => nil)
    end
  end
  
end
