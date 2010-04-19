class OnHandler
  attr :name
  def initialize(name)
    @name=name
  end
  def interested?(event)
    event.name == @name
  end
end

class E
  def name; "xx"; end
end

o=OnHandler.new "xxx"
puts o.interested?(E.new)