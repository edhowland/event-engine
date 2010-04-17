module EventEngine
  module Proc
    include AlwaysInterested
    def handle event
      result=self.call event
      event
    end
  end
end