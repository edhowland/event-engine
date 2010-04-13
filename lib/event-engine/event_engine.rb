module EventEngine
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
        raise StandardError.new 'nyi'
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
    
  end
  
end