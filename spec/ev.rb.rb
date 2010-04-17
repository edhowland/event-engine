class Ev 
  attr :started, :ended, :name
  def initialize(name); @name=name; end
  def started!; @started=true; end
  def started?; @started; end
  def ended!; @ended=true; end
  def ended?; @ended; end
end

e=Ev.new :n
e.ended!
puts e.ended?