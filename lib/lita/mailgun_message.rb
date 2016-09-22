require 'json'

module Lita
  class MailgunMessage
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def subject
      @data.fetch("subject")
    end

    def recipient
      @data.fetch("recipient")
    end

    def from
      @data.fetch("from")
    end

    def body_plain
      @data.fetch("body-plain")
    end

    def body_html
      @data.fetch("body-html")
    end

    def attachment_count
      @data.fetch("attachment-count", 0).to_i
    end

    # num is 1 indexed
    def attachment(num)
      @data.fetch("attachment-#{num}", nil)
    end

    def to_json
      JSON.pretty_generate(@data)
    end

    def inspect
      @data.inspect
    end

  end
end
