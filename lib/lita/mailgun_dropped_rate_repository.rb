require "ostruct"
require "bigdecimal"
require "thread"

module Lita
  class MailgunDroppedRateRepository
    VALID_EVENTS = [:delivered, :dropped]

    class DroppedResult
      attr_reader :domain, :dropped, :total

      def initialize(domain, dropped, total)
        @domain, @dropped, @total = domain, dropped.to_i, total.to_i
      end

      def dropped_rate
        (BigDecimal.new(dropped) / BigDecimal.new(total) * 100).round(3)
      end
    end
    
    def initialize
      @store = {}
      @mutex = Mutex.new
    end

    def record(domain, event_name)
      return false unless valid_event?(event_name)

      @mutex.synchronize do
        @store[domain] ||= []
        @store[domain] << event_name
        if @store[domain].size > 100
          @store[domain] = @store[domain].silce(-100, 100)
        end
      end
      true
    end

    def dropped_rate(domain)
      @mutex.synchronize do
        DroppedResult.new( domain, dropped_count(domain), total_count(domain) )
      end
    end

    private

    def dropped_count(domain)
      return 0 if @store[domain].nil?

      @store[domain].select { |item|
        item == :dropped
      }.size
    end

    def total_count(domain)
      return 0 if @store[domain].nil?

      @store[domain].size
    end

    def valid_event?(event_name)
      VALID_EVENTS.include?(event_name)
    end
  end
end
