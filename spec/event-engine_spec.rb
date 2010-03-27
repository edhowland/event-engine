require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "EventEngine" do
  $handled = false
  module SimpleHanlder
    include AlwaysInterested
    def handle event
      $handled = true
      event
    end
  end
  
  describe "initialization" do
    it "should not have a Fiber yet" do
      eng = EventEngine::Engine.new
      eng.fiber.should be_nil
    end
    
  end
  
  before(:each) do
    @eng = EventEngine::Engine.new
    @eng.run do |em|
      em.handle SimpleHanlder 
    end
  end

  it "should add the handler" do
    @eng.handlers.should_not be_empty
  end
  
  it "should have an empty eventq" do
    @eng.eventq.should be_empty
  end

  it "should have a non-empty eventq after triggered" do
    @eng.eventq.should_receive(:push).with(any_args()).and_return(nil)
    @eng.trigger Object.new
    @eng.eventq.should be_empty
  end

  it "should trigger event" do
    @eng.trigger Object.new
    $handled.should be_true
  end
  
  describe "Handler chain" do
    class Event
      attr_accessor :started, :ended
      def initialize
        @started = false
        @ended = false
      end
      def start
        @started = true
        self
      end
      def stop
        @ended = true
        self
      end
    end
    module StartChain
      include AlwaysInterested
      def handle event
        event.start
      end
    end
    module EndChain
      include AlwaysInterested
      def handle event
        raise StandardError.new unless event.started
        event.stop
      end
    end
    before(:each) do
      @eng.run do |en|
        en.handle StartChain
        en.handle EndChain
      end
    end
    it "should only have 2 handlers" do
      @eng.handlers.length.should == 2
    end
    it "should start and stop the event" do
      ev = Event.new
      ev.started.should_not be_true
      ev.ended.should be_false
      @eng.trigger ev
      ev.started.should be_true
      ev.ended.should be_true
    end
  end
  describe "Multiple Events" do
    it "should handle multiple events" do
      @eng.trigger Object.new
      @eng.trigger Object.new
      @eng.eventq.should be_empty
    end
  end
end
