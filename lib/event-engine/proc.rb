module EventEngine
  module Proc
    include AlwaysInterested
    def handle event
      result=self.call event
      result or event
    end
  end
end