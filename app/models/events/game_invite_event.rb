class GameInviteEvent < Event
  def initialize(game)
    self.game_id = game.key
    self.source_user = game.white_player
    self.user_id = game.black_player.id
    self.payload = {
      :game => {
        :id => game.id
      },
      :board_size => game.board_size,
      :source_user => {
        :id => self.source_user.id,
        :name => self.source_user.name,
        :handle => self.source_user.handle,
        :description => self.source_user.description
      }
    }
  end
end
