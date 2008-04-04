require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Main, "index action" do
  before(:each) do
    dispatch_to(Main, :index)
  end
end