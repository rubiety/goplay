class UserEnteredEvent < Event
  def initialize(user)
    self.source_user = user
    self.payload = {
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
