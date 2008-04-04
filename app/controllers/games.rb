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
    @opponent = @game.white_player == current_user ? @game.black_player : @game.white_player
    content_type :html
    headers['Content-Type'] = 'application/xhtml+xml'
    render
  end
  
  # GET /games/new
  def new
    only_provides :html
    @game = Game.new
    render :layout => false
  end
  
  # GET /games/1/edit
  def edit
    only_provides :html
    render
  end
  
  # POST /games
  def create
    @game = Game.new(params[:game])
    @game.white_player = current_user
    @game.black_player = @opponent
    
    if @game.save
      redirect url(:game, @game)
    else
      render :new
    end
  end
  
  # POST /games/1/accept
  def accept
    @game.accept if @game.black_player == current_user
    redirect url(:game, @game)
  end
  
  # POST /games/1/reject
  def reject
    @game.reject if @game.black_player == current_user
    redirect url(:users)
  end
  
  # PUT /games/1
  def update
    if @game.update_attributes(params[:game])
      redirect url(:game, @game)
    else
      render :edit
    end
  end
  
  # DELETE /games/1
  def destroy
    if @game.destroy!
      redirect url(:game)
    else
      raise BadRequest
    end
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
  
end
