require "lita"
require 'lita/mailgun_event'
require 'lita-timing'

module Lita
  module Handlers
    # Watch mailgun webhooks for successful and dropped deliveries, and report any domains
    # with a high dropped rate
    class MailgunDroppedRate < Handler
      ONE_HOUR = 60 * 60

      config :channel_name

      on :mailgun_event, :monitor_event

      def monitor_event(payload)
        event = payload[:event]

        repository.record(event.recipient_domain, event.name.to_sym)

        persistent_every(event.recipient_domain, ONE_HOUR) do
          result = repository.dropped_rate(event.recipient_domain)
          robot.send_message(target, result_to_message(result))
        end
      end

      private

      def result_to_message(result)
        "[mailgun] [#{result.domain}] #{result.dropped}/#{result.total} (#{result.dropped_rate.to_s("F")}%) recent emails dropped"
      end

      def repository
        @@repository ||= MailgunDroppedRateRepository.new
      end

      def target
        Source.new(room: Lita::Room.find_by_name(config.channel_name) || "general")
      end

      def persistent_every(name, seconds, &block)
        Lita::Timing::RateLimit.new(name, redis).once_every(seconds, &block)
      end
    end

    Lita.register_handler(MailgunDroppedRate)
  end
end