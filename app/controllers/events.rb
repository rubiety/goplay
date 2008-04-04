class Events < Application
  provides :xml, :yaml, :js
  
  before :fetch_unconsumed_events, :only => [:index]
  before :fetch_event, :exclude => [:index, :new, :create]
  
  # GET /users/current/events
  def index
    @events.each {|e| e.consumed_at = Time.now; e.save }
    display @events
  end
  
  # GET /users/current/events/1
  def show
    @event = Event.first(params[:id])
    raise NotFound unless @event
    display @event
  end
  
  # POST /users/current/events
  def create
    @event = Event.new(params[:event])
    if @event.save
      redirect url(:event, @event)
    else
      render :new
    end
  end
  
  # DELETE /users/current/events/1
  def destroy
    if @event.destroy!
      redirect url(:event)
    else
      raise BadRequest
    end
  end
  
  
  private
  
  def fetch_user
    @user = current_user
    raise NotFound unless @user
  end
  
  def fetch_unconsumed_events
    fetch_user
    @events = Event.all(:user_id => current_user.id, :consumed_at => nil)
  end
  
  def fetch_event
    fetch_user
    @event = @user.events(:id => params[:id])
    raise NotFound unless @event
  end
  
end
