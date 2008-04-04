require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Moves, "index action" do
  before(:each) do
    dispatch_to(Moves, :index)
  end
end