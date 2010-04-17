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
    @eng.setup do |em|
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
      @eng.setup do |en|
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
  describe "Proc handlers" do
    before(:each) do
      @eng=EventEngine::Engine.new
    end
    it "should take a Module as a handler" do
      module Test
        def handle event
        end
      end
      @eng.setup do |en|
        en.handle Test
      end
    end
    it "should take a proc as a handler" do
      @eng.setup do |e|
        e.handle -> {1}
      end
    end
    it "should handle a as a Proc acceptiing an event" do
      @eng.setup do |e|
        e.handle ->(e) {e}
      end
    end
    describe "handle as a Proc" do
      class Event1
        attr_accessor :flag
      end
      before(:each) do
        @eng.setup do |e|
          e.handle ->(ev) {ev.flag=true}
        end
      end
      it "should see flag is not nil after trigger" do
        ev=Event1.new
        @eng.trigger ev
        ev.flag.should_not be_nil
      end
    end
    describe "returning event from handler" do
      class Ev1; attr_accessor :flag; end
      before(:each) do
        @ev = Ev1.new
      end
      it "should grt initial event" do
        @eng.setup do |e|
          e.handle ->(ev) {raise StandardError.new unless ev}
        end
        @eng.trigger @ev
      end
      it "should return event from first handler returning nil" do
        @eng.setup do |e|
          e.handle ->(ev) {nil}
          e.handle ->(ev) {raise StandardError.new unless ev}
        end
        @eng.trigger @ev
      end
    end
    describe "chaining proc handlers" do
      class Event2
        attr_accessor :count
        def initialize; @count = 1; end
        def incr
          @count += 1
        end
      end
      before(:each) do
       @eng.setup do |en|
        en.handle ->(ev) {Event2.new}
        en.handle ->(ev) {ev.should_not be_nil; ev}
        en.handle ->(ev) {ev.should be_kind_of(Event2); ev}
        en.handle ->(ev) {ev.incr; ev}
        en.handle ->(ev) {puts ev.count; ev}
        en.handle ->(ev) {raise StandardError.new unless ev.count==2}
       end
      end
      it "should bypass the event and return its own" do
        ->{@eng.trigger Event2.new}.should_not raise_error
      end
    end
  end
end
