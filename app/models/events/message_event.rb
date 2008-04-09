class MessageEvent < Event
  def initialize(message)
    self.game = message.game if message.game
    self.user = message.game.opponent_of(message.user) if message.game
    self.source_user = message.user
    self.payload = {
      :message => message.message,
      :sender => {
        :name => self.source_user.name,
        :handle => self.source_user.handle
      }
    }
  end
end
