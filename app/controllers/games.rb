# == Games
# A tradional REST resource representing a game.  
# 
class Games < Application
  provides :xml, :yaml, :js
  
  before :login_required
  before :fetch_all_games, :only => [:index]
  before :fetch_game, :exclude => [:index, :new, :create]
  before :fetch_opponent, :only => [:new, :create]
  
  # GET /games
  def index
    display @games
  end
  
  # GET /games/1
  def show
    @message = Message.new
    @opponent = @game.opponent_of(current_user)
    
    case content_type
    when :xml
      @game.to_xml
    when :js
      @game.to_json(current_user)
    when :yaml
      @game.to_yaml
    else
      render_compound_document :layout => 'window'
    end
  end
  
  # GET /games/new
  def new
    only_provides :html
    @game = Game.new
    render :layout => false
  end
  
  # POST /games
  def create
    @game = Game.new(params[:game])
    @game.white_player = current_user
    @game.black_player = @opponent
    
    case content_type
    when :js
      if @game.save
        {:game_id => @game.to_param}.to_json
      else
        {:errors => @game.errors}.to_json
      end
      
    else
      if @game.save
        redirect url(:game, @game)
      else
        render :new
      end
      
    end
  end
  
  # POST /games/1/accept
  def accept
    @game.accept! if @game.black_player == current_user
    redirect url(:game, @game)
  end
  
  # POST /games/1/reject
  def reject
    @game.reject! if @game.black_player == current_user
    redirect url(:users)
  end
  
  # POST /games/1/leave
  def leave
    @game.cancel!
    GameEndEvent.new(@game, @game.opponent_of(current_user)).enqueue
    redirect url(:users)
  end
  
  
  private
  
  def fetch_all_games
    @games = Game.all
  end
  
  def fetch_game
    @game = Game[params[:id]]
    raise NotFound unless @game
  end
  
  def fetch_opponent
    @opponent = User[params[:opponent_id].to_i] if params[:opponent_id]
  end
  
  # Correctly handles compound document rendering with MIME type
  def render_compound_document(*args)
    headers['Content-Type'] = 'application/xhtml+xml'
    render(*args)
  end
  
end
