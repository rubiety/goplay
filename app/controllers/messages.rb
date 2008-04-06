# == Messages Controller
# Standard REST resource representing a "message".  Can be used in 
# both global context and game context, which represents messages 
# only for a particular game.
# 
class Messages < Application
  provides :xml, :yaml, :js
  
  before :login_required
  
  before :fetch_all_messages, :only => [:index]
  before :fetch_message, :exclude => [:index, :new, :create]
  
  # GET /game/1/messages
  # GET /messages
  def index
    display @messages
  end
  
  # GET /game/1/messages/1
  # GET /messages/1
  def show
    display @message
  end
  
  # GET /game/1/messages/new
  # GET /messages/new
  def new
    only_provides :html
    @message = Message.new
    render
  end
  
  # POST /game/1/messages
  # POST /messages
  def create
    @message = Message.new(params[:message])
    @message.user = current_user
    
    if @message.save
      redirect url(:users)
    else
      render :new
    end
  end
  
  
  private
  
  def fetch_game
    @game = Game[params[:game_id]] if params[:game_id]
  end
  
  def fetch_all_messages
    fetch_game
    @messages = @game ? @game.messages : Message.all
  end
  
  def fetch_message
    fetch_game
    @message = @game ? @game.messages.first(params[:id]) : Message[params[:id]]
    raise NotFound unless @message
  end
  
end
