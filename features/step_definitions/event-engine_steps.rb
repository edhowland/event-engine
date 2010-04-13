Given /^I have an Event Engine$/ do
  @engine = EventEngine::Engine.new
  @flag = false
end
# And I tell it to handle all events with a Proc
Given /^I tell it to handle all events with a Proc$/ do
  @engine.setup do |eng|
    eng.handle ->(ev){@flag=true}
  end
end
# When I trigger an event
When /^I trigger an event$/ do
  @engine.trigger Object.new
end
# Then The proc should fire
Then /^The proc should fire$/ do
  @flag.should be_true
end