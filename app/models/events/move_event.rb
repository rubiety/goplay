class MoveEvent < Event
  def initialize(move)
    self.game = move.game
    self.source_user = move.user
    self.payload = {:row => move.row, :column => move.column}
  end
end
