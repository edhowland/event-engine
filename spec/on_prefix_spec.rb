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
  
  it "should be subscribed to both events and no others" do
    @eng.setup do |e|
      e.on_start {|ev|}
      e.on_end {|ev|}
    end
    @eng.subscribers(Ev.new("start")).length.should == 1
    @eng.subscribers(Ev.new("end")).length.should == 1
    @eng.subscribers(Ev.new("xxx")).length.should == 0
  end

  it "should be subscribed to the correct events" do
    @eng.setup do |e|
      e.on_start {|ev|}
      e.on_end {|ev|}
    end
    st=Ev.new("start")
    ed=Ev.new("end")
    @eng.subscribers(st)[0].interested?(st).should be_true
    @eng.subscribers(st)[0].interested?(ed).should be_false
    @eng.subscribers(ed)[0].interested?(ed).should be_true
    @eng.subscribers(ed)[0].interested?(st).should be_false
  end
  
  it "should handle the subscibed event" do
    @eng.setup do |e|
      e.on_start {|ev| fail}
      e.on_end {|ev|}
      e.on_xxx {|ev|}
    end
    st=Ev.new("start")
    ed=Ev.new("end")
    -> {@eng.subscribers(st)[0].handle(st)}.should raise_error
    -> {@eng.subscribers(ed)[0].handle(ed)}.should_not raise_error
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
  
  it "should allow 3 char event names" do
    @eng.setup do |e|
      e.on_end {|ev| }
    end
    @eng.handlers[0].interested?(Ev.new("end")).should be_true
  end
  
  it "should have only interest in thier on_prefix" do
    @eng.setup do |e|
      e.on_end {|ev| ev.ended!}
      e.on_start {|ev| ev.started!}
    end
    @eng.handlers.length.should == 2
    @eng.handlers[0].interested?(Ev.new("end")).should be_true
    @eng.handlers[0].interested?(Ev.new("started")).should_not be_true
    @eng.handlers[1].interested?(Ev.new("start")).should be_true
    @eng.handlers[1].interested?(Ev.new("end")).should_not be_true
  end

  it "should do both start and end" do
    @eng.setup do |e|
      e.on_start {|ev| ev.started!}
      e.on_end {|ev| ev.ended!}
    end
    st = Ev.new "start"
    ed = Ev.new "end"
    [st, ed].each {|ev| @eng.trigger ev}
    st.started?.should be_true
    ed.ended?.should be_true
  end
  
  class FileSysEvent
    attr :dir, :file
    def initialize(file_or_dir)
      @dir = file_or_dir == :dir
      @file = file_or_dir == :file
    end
    def file?
      @file
    end
    def directory?
      @dir
    end      
  end
  
  it "should fire on dir predicate" do
    @was_dir = false
    @eng.setup do |e|
      e.on_directory {|ev| @was_dir=true}
    end
    @eng.trigger FileSysEvent.new(:dir)
    @was_dir.should be_true
  end
  it "should fire on file predicate" do
    @was_file = false
    @eng.setup do |e|
      e.on_file {|ev| @was_file=true}
    end
    @eng.trigger FileSysEvent.new(:file)
    @was_file.should be_true
  end
  it "should handle both file and dir predicates" do
    @was_dir = false
    @was_file = false
    @eng.setup do |e|
      e.on_directory {|ev| @was_dir=true}
      e.on_file {|ev| @was_file=true}
    end
    @eng.trigger FileSysEvent.new(:dir)
    @eng.trigger FileSysEvent.new(:file)

    @was_dir.should be_true
    @was_file.should be_true
  end
end
