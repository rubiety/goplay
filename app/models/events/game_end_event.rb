class GameEndEvent < Event
  def initialize(game)
    self.game = game
    self.payload = {
      :completed_status => game.completed_status,
      :white_won => game.white_won
    }
  end
end
