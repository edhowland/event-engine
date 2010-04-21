#!/usr/bin/env ruby -wKU
require "stringio"
class StringFromIO < String
  attr :nio
  def initialize
    @nio = StringIO.new
  end
  def to_s
    @nio.string
  end
  def +(append)
    to_s + append
  end
end

hst = StringFromIO.new
$oldstdout, $stdout = $stdout, hst.nio

puts "hello"

$stdout = $oldstdout
puts hst + " world"