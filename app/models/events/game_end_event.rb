class GameEndEvent < Event
  def initialize(game, user)
    self.game = game
    self.user = user
    self.payload = {
      :completed_status => game.completed_status,
      :white_won => game.white_won
    }
  end
end
