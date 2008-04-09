# == Game Moves
# Standard REST resource representing a move in a game.
# Creating a move implies a user making a move within a game.
# Can only be used within game context.  Moves can only be listed 
# or created. 
# 
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
    
    move_captures = []
    move_errors = []
    
    begin
      @move.save
      
      @move.captures do |capture|
        move_captures << {:row => capture.row, :column => capture.column}
      end
      
    rescue Board::MoveTargetExistsError => e
      move_errors << 'Invalid Move: Move target already exists!'
    rescue Board::RuleOfKoError => e
      move_errors << 'Invalid Move: Rule of Ko'
    rescue Board::SuicidalMoveError => e
      move_errors << 'Invalid Move: This move would be suicidal!'
    end
    
    case content_type
    when :xml
      {:errors => move_errors, :captures => move_captures}.to_xml
    when :yaml
      {:errors => move_errors, :captures => move_captures}.to_yaml
    when :js
      {:errors => move_errors, :captures => move_captures}.to_json
    else
      redirect url(:users)
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
