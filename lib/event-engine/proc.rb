module EventEngine
  module Proc
    include AlwaysInterested
    def handle event
      self.call event
    end
  end
end