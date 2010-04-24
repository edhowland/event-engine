require "pp"
require "stringio"

class NilClass
  def empty?; true; end
end

class StringFromIO < String
  attr :nio
  def initialize
    @nio = StringIO.new
  end
  def to_s
    @nio.string
  end
  def +(append)
    to_s + append
  end
end



Before do
  # @last_stdout = StringFromIO.new
  # $oldstdout, $stdout = $stdout, @last_stdout.nio

  # @last_stdout = StringIO.new
  # $old_stdout, $stdout = $stdout, @last_stdout
  @last_stdout = ""
  @last_stderr = ""
end


Given /show me the environment/ do
  pp self
end

Given /^I have an Event Engine$/ do
  @evals = []
  @engine = EventEngine::Engine.new
  @flag = false
end



Given /^I tell it to handle all events with a Proc$/ do
  @engine.setup do |eng|
    eng.handle ->(ev){@flag=true}
  end
end

When /^I trigger an event$/ do
  @engine.trigger Object.new
end

Then /^The proc should fire$/ do
  @flag.should be_true
end

Given /^(.+) is (.+)/ do |var, value|
  eval "@#{var}=#{value}"
end

class Ev
  attr :name
  def initialize(name); @name=name; end
end


Given /^I tell it to handle on_(.+)$/ do |handler|
  @evals << "e.on_#{handler} {@#{handler}ed=true}"
end

Given /^I tell it to setup those handlers$/ do
  @engine.setup do |e|
    @evals.each {|v| eval v}
  end
end

When /^I trigger the (.+) event$/ do |name|
  ev=Ev.new(name.downcase)
  @engine.trigger ev
end

Then /^(.+) has become true$/ do |variable|
  eval("@#{variable}").should be_true
end

Then /^(.+) has become false$/ do |variable|
  eval("@#{variable}").should_not be_true
end

Given /^I give it predicate (.+) with '([^']+)'$/ do |filter, proc|
  @evals << "e.#{filter} #{proc}"
end

Given /^show me the evals$/ do
  announce(@evals.inspect)
end

Given /^I have the following directory structure$/ do |table|
  table.hashes.each do |row|
    create_dir(row[:dir])
    create_file(File.join(row[:dir], row[:file]), "") unless row[:file].empty?
  end
end

When /^I trigger using a Dir$/ do
  Dir.chdir "tmp/aruba" do |dir|
    Dir['**/*'].each {|d|  @engine.trigger Pathname.new(d)}
  end
end