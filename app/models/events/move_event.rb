class MoveEvent < Event
  def initialize(move)
    self.game = move.game
    self.source_user = move.user
    self.user = move.game.opponent_of(self.source_user)
    self.payload = {
      :pass => move.pass,
      :row => move.row, 
      :column => move.column,
      :captures => move.captures.map {|c| {:row => c.row.to_i, :column => c.column.to_i}}
    }
  end
end
