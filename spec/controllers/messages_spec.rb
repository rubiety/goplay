require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe ChatMessages, "index action" do
  before(:each) do
    dispatch_to(ChatMessages, :index)
  end
end