#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require "pathname"
require "event-engine"

eng = EventEngine::Engine.new

eng.setup do |en|
  en.on_file {|ev| puts "file: " + ev.to_s}
  en.on_directory {|ev| puts "dir: " + ev.to_s}
  # en.handle ->(ev) {puts ev.to_s}
end

# walk tree triggering events for each node
Dir['../**/*'].each {|l| eng.trigger Pathname.new(l)}