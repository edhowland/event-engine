#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "event-engine"

eng = EventEngine::Engine.new

eng.setup do |en|
  en.handle ->(ev) {puts ev.to_s}
end

# walk tree triggering events for each node
Dir['../**/*'].each {|l| eng.trigger l}