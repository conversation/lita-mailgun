require "lita"
require "lita/mailgun_event"

module Lita
  module Handlers
    # Receives buildkite webhooks and emits them onto the lita event bus
    # so other handlers can do their thing
    class Mailgun < Handler

      http.post "/mailgun", :mailgun_event

      def mailgun_event(request, response)
        body = request.body.read
        event = MailgunEvent.new(body)
        robot.trigger(:mailgun_event, event: event)
        robot.send_message(target, pretty_json(body))
      end

      private

      def target
        Source.new(room: Lita::Room.find_by_name("tcbot-testing") || "general")
      end

			def pretty_json(serialised_json_data)
				deserialised_data = JSON.parse(serialised_json_data)
				JSON.pretty_generate(deserialised_data)
			rescue JSON::ParserError
				'{"error":"Unable to parse data"}'
			end

    end

    Lita.register_handler(Mailgun)
  end
end
