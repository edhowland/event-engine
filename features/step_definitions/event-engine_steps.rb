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

Given /^(.+) is (.+)/ do |var, value|
  eval "@#{var}=#{value}"
end

# And I tell it to handle on_start
Given /^I tell it to handle on_(.+)$/ do |handler|
  @engine.setup do |e|
    eval "e.on_#{handler} {@#{handler}ed=true}"
  end
end

# When I trigger Start event
When /^I trigger Start event$/ do
  pending # express the regexp above with the code you wish you had
end
# When I trigger End event
When /^I trigger End event$/ do
  pending # express the regexp above with the code you wish you had
end
