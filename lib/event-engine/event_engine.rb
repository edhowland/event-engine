module EventEngine
  class Engine
    attr_accessor :handlers, :eventq, :fiber
    def initialize
      @handlers = []
      @eventq = []
      @fiber = nil
    end
    def handle handler
      @handlers.push Object.new.extend handler
    end
    def run &block
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