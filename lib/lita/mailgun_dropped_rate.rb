require "lita"
require 'lita/mailgun_event'

module Lita
  module Handlers
    # Watch mailgun webhooks for successful and dropped deliveries, and report any domains
    # with a high dropped rate
    class MailgunDroppedRate < Handler
      config :channel_name

      on :mailgun_event, :monitor_event

      def monitor_event(payload)
        event = payload[:event]

        robot.send_message(target, "[mailgun] [#{event.name}] #{event.recipient_domain}")
      end

      private

      def target
        Source.new(room: Lita::Room.find_by_name(config.channel_name) || "general")
      end

    end

    Lita.register_handler(MailgunDroppedRate)
  end
end
