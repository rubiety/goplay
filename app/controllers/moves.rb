class Moves < Application
  provides :xml, :yaml, :js
  
  before :login_required
  
  before :get_moves, :only => [:index]
  before :get_move, :exclude => [:index, :new, :create]
  
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
    @move = Move.new(params[:mof])
    if @move.save
      redirect url(:mof, @mof)
    else
      render :new
    end
  end
  
  # DELETE /game/1/moves/1
  def destroy
    @move = Move.first(params[:id])
    raise NotFound unless @mof
    if @move.destroy!
      redirect url(:mof)
    else
      raise BadRequest
    end
  end
  
  
  private
  
  def get_game
    @game = Game[params[:id]]
    raise NotFound unless @game
  end
  
  def get_moves
    get_game
    @moves = @game.moves
  end
  
  def get_move
    get_game
    @move = @game.moves.first(params[:id])
    raise NotFound unless @move
  end
  
end
