module EventEngine
  module MethodMaker
    def symbolize(arg, append); (arg.to_s+append).to_sym; end
    def imperative(arg); symbolize(arg, '!'); end
    def predicate(arg); symbolize(arg, '?'); end
    
    def create_method(name, &block)
      self.class.send(:define_method, name, &block)
    end
  end
  
  class Engine
    attr_accessor :handlers, :eventq, :fiber
    def initialize
      @handlers = []
      @eventq = []
      @fiber = nil
    end
    def handle handler
      if handler.kind_of? Module
        @handlers.push Object.new.extend handler
      elsif handler.respond_to? :call
        @handlers.push handler.extend EventEngine::Proc
      else
        # raise StandardError.new 'nyi'
        @handlers.push handler
      end
    end
    def setup &block
      @handlers.clear
      @fiber = Fiber.new do
        loop do
          Fiber.yield @eventq.shift
        end
      end
      
      yield self
    end
    
    def dispatch event
      @handlers.select {|h| h.interested? event}.inject(event) {|ev, h| h.handle ev}
    end
    
    
    def trigger event
      @eventq.push event
      event = @fiber.resume
      dispatch event
    end

    def remove_prefix string
      string[3..-1]
    end
    
    def method_missing(name, *args, &block)
      o=Object.new.extend MethodMaker
      o.create_method o.predicate(:interested) do |event|
        event.name == name[3..-1]
      end
      o.create_method :handle, &block
      
      handle o
    end
  end
  
end