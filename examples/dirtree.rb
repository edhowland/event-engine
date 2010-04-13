#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "event-engine"

module Dirtree
  include AlwaysInterested
  def handle event
    puts event.to_s
  end
end

eng = EventEngine::Engine.new

eng.run do |en|
  en.handle Dirtree
end

Dir['../**/*'].each {|l| eng.trigger l}