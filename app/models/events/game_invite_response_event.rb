class GameInviteResponseEvent < Event
  def initialize(game)
    self.game = game
    self.source_user = game.black_player
    self.user = game.white_player
    self.payload = {
      :response => game.status,
      :source_user => {
        :id => self.source_user.id,
        :name => self.source_user.name,
        :handle => self.source_user.handle,
        :description => self.source_user.description,
        :gravatar_url => self.source_user.gravatar_url
      }
    }
  end
end
