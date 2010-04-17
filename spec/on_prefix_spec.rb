require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "On Prifix" do
  before(:each) do
    @eng = EventEngine::Engine.new
  end
  it "should allow on_start handle" do
    @eng.setup do |e|
      e.on_start {|ev|}
    end
    @eng.handlers.should_not be_empty
  end
  class Ev 
    attr :started, :ended, :name
    def initialize(name); @name=name; end
    def started!; @started=true; end
    def started?; @started; end
    def ended!; @ended=true; end
    def ended?; @ended; end
  end
  it "should parse the on_prefix" do
    @eng.remove_prefix("on_start").should == "start"
  end
  it "should have a handler that responds to :interested?" do
    @eng.setup do |e|
      e.on_start {|ev| ev.started!}
    end
    @eng.handlers.first.respond_to?(:interested?).should be_true
  end
  it "should call the on_ method" do
    @eng.setup do |e|
      e.on_start {|ev| ev.started!}
    end
    ev = Ev.new 'start'
    @eng.trigger ev 
    ev.started?.should be_true
  end
  it "should fire only on start" do
    @eng.setup do |e|
      e.on_start {|ev| ev.started!}
      e.on_end {|ev| ev.ended!}
    end
    ev = Ev.new "start"
    @eng.trigger ev
    ev.ended?.should_not be_true
  end
  
end
