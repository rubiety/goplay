class MoveEvent < Event
  def initialize(move)
    self.game = move.game
    self.source_user = move.user
    self.user = move.game.white_player == self.source_user ? move.game.black_player : move.game.white_player
    self.payload = {:row => move.row, :column => move.column}
  end
end
