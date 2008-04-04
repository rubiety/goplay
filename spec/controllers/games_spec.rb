require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Games, "index action" do
  before(:each) do
    dispatch_to(Games, :index)
  end
end