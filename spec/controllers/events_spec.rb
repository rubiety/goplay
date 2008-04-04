require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Events, "index action" do
  before(:each) do
    dispatch_to(Events, :index)
  end
end