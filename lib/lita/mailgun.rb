require "lita"
require "lita/mailgun_event"

module Lita
  module Handlers
    # Receives buildkite webhooks and emits them onto the lita event bus
    # so other handlers can do their thing
    class Mailgun < Handler

      http.post "/mailgun", :mailgun_event

      def mailgun_event(request, response)
        event = MailgunEvent.new(request.params)
        robot.trigger(:mailgun_event, event: event)
      end

    end

    Lita.register_handler(Mailgun)
  end
end
