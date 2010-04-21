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
    
    def subscribers(event)
      @handlers.select {|h| h.interested? event}
    end
    
    def dispatch event
      subscribers(event).inject(event) {|ev, h| h.handle ev}
    end
    
    def trigger event
      @eventq.push event
      event = @fiber.resume
      dispatch event
    end
    
    class OnHandler
      attr :name, :proc
      
      def initialize(name, proc)
        @name=name
        @proc=proc
      end
      def pred!
        (@name + '?').to_sym 
      end
      def interested?(event)
        if event.respond_to?(:name)
          event.name == @name
        elsif event.respond_to?(pred!)
          event.send pred!
        end
      end
      def handle event
        @proc.call(event)
        event
      end
    end
    def method_missing(name, *args, &block)
      o=OnHandler.new(name[3..-1], block)

      handle o
    end
  end
  
end