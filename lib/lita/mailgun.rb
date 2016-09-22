require "lita"
require "lita/mailgun_event"
require "lita/mailgun_message"

module Lita
  module Handlers
    # Receives buildkite webhooks and emits them onto the lita event bus
    # so other handlers can do their thing
    class Mailgun < Handler

      http.post "/mailgun", :mailgun_event
      http.post "/mailgun_incoming", :mailgun_incoming

      def mailgun_event(request, response)
        event = MailgunEvent.new(request.params)
        robot.trigger(:mailgun_event, event: event)
      end

      def mailgun_incoming(request, response)
        message = MailgunMessage.new(request.params)
        robot.trigger(:mailgun_incoming, message: message)
      end

    end

    Lita.register_handler(Mailgun)
  end
end
