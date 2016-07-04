require "lita"
require 'lita/mailgun_event'
require 'lita-timing'

module Lita
  module Handlers
    # Watch mailgun webhooks for successful and dropped deliveries, and report any domains
    # with a high dropped rate
    class MailgunDroppedRate < Handler
      ONE_HOUR = 60 * 60
      REPORTING_THRESHOLD_PERCENT = 50 # percent
      REPORTING_THRESHOLD_ADDRESSES = 2 # uniq addresses

      config :channel_name

      on :mailgun_event, :monitor_event

      def monitor_event(payload)
        event = payload[:event]

        repository.record(event.recipient, event.name.to_sym)

        result = repository.dropped_rate(event.recipient_domain)
        if result.dropped_rate >= REPORTING_THRESHOLD_PERCENT && result.uniq_dropped >= REPORTING_THRESHOLD_ADDRESSES
          persistent_every(event.recipient_domain, ONE_HOUR) do
            robot.send_message(target, result_to_message(result))
          end
        end
      end

      private

      def result_to_message(result)
        "[mailgun] [#{result.domain}] recent emails: #{result.total}, addresses with failed deliveries: #{result.uniq_dropped}/#{result.uniq_addresses} (#{result.dropped_rate.to_s("F")}%)"
      end

      def repository
        @repository ||= MailgunDroppedRateRepository.new(redis)
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
