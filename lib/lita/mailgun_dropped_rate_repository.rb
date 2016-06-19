require "ostruct"
require "bigdecimal"
require 'json'

module Lita
  class MailgunDroppedRateRepository
    VALID_EVENTS = [:delivered, :dropped]
    TWO_WEEKS = 60 * 60 * 24 * 7 * 2

    class DroppedResult
      attr_reader :domain, :dropped, :total

      def initialize(domain, dropped, total)
        @domain, @dropped, @total = domain, dropped.to_i, total.to_i
      end

      def dropped_rate
        (BigDecimal.new(dropped) / BigDecimal.new(total) * 100).round(3)
      end
    end

    def initialize(redis)
      @redis = redis
    end

    def record(recipient, event_name)
      return false unless valid_event?(event_name)

      domain = extract_domain(recipient)

      key = "events-#{domain}"
      data = {event: event_name, domain: domain, recipient: recipient, at: Time.now.to_i}
      @redis.rpush(key, JSON.dump(data))
      @redis.ltrim(key, -20, -1)
      @redis.expire(key, TWO_WEEKS)
      true
    end

    def dropped_rate(domain)
      events = fetch_events(domain) || []

      DroppedResult.new( domain, dropped_count(events), events.size )
    end

    private

    def extract_domain(email)
      email.to_s.split("@").last || "unknown"
    end

    def dropped_count(events)
      events.select { |item|
        item["event".freeze] == "dropped".freeze
      }.size
    end

    def fetch_events(domain)
      key = "events-#{domain}"

      @redis.lrange(key, 0, 19).map { |data|
        JSON.load(data)
      }
    end

    def valid_event?(event_name)
      VALID_EVENTS.include?(event_name)
    end
  end
end
