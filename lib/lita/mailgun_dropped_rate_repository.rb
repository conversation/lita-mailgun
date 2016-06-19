require "ostruct"
require "bigdecimal"

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

    def record(domain, event_name)
      return false unless valid_event?(event_name)

      key = "events-#{domain}"
      @redis.rpush(key, event_name.to_s)
      @redis.ltrim(key, -20, -1)
      @redis.expire(key, TWO_WEEKS)
      true
    end

    def dropped_rate(domain)
      DroppedResult.new( domain, dropped_count(domain), total_count(domain) )
    end

    private

    def dropped_count(domain)
      fetch_events(domain).select { |item|
        item == "dropped".freeze
      }.size
    end

    def total_count(domain)
      fetch_events(domain).size
    end

    def fetch_events(domain)
      key = "events-#{domain}"

      list = @redis.lrange(key, 0, 19)
    end

    def valid_event?(event_name)
      VALID_EVENTS.include?(event_name)
    end
  end
end
