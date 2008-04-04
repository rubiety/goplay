class Moves < Application
  provides :xml, :yaml, :js
  
  before :login_required
  
  before :fetch_all_moves, :only => [:index]
  before :fetch_move, :exclude => [:index, :new, :create]
  
  # GET /game/1/moves
  def index
    @moves = Move.all
    display @moves
  end
  
  # GET /game/1/moves/new
  def new
    only_provides :html
    @mof = Move.new
    render
  end
  
  # POST /game/1/moves
  def create
    fetch_game
    @move = Move.new(:row => params[:row], :column => params[:column])
    @move.game = @game
    @move.user = current_user
    
    if @move.save
      ''
    else
      render :new
    end
  end
  
  # DELETE /game/1/moves/1
  def destroy
    @move = Move.first(params[:id])
    raise NotFound unless @mof
    if @move.destroy!
      redirect url(:moves)
    else
      raise BadRequest
    end
  end
  
  
  private
  
  def fetch_game
    @game = Game[params[:game_id].to_i]
    @game = nil unless [@game.white_player, @game.black_player].include?(current_user)
    raise NotFound unless @game
  end
  
  def fetch_all_moves
    fetch_game
    @moves = @game.moves
  end
  
  def fetch_move
    fetch_game
    @move = Move.all(:id => params[:id], :game_id => @game.id)
    raise NotFound unless @move
  end
  
end
