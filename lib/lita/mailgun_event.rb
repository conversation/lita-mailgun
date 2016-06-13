module Lita
  class MailgunEvent
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def name
      @data.fetch("event")
    end

    def recipient
      @data.fetch("recipient")
    end

    def recipient_domain
      recipient.split("@").last
    end

  end
end
