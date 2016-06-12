module Lita
  class MailgunEvent
    attr_reader :data

    def initialize(data)
      @data = JSON.load(data)
    end

  end
end
