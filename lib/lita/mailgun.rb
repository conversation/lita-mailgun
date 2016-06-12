require "lita"
require "lita/mailgun_event"

module Lita
  module Handlers
    # Receives buildkite webhooks and emits them onto the lita event bus
    # so other handlers can do their thing
    class Mailgun < Handler

      http.post "/mailgun", :mailgun_event

      def mailgun_event(request, response)
        robot.send_message(target, "```" + JSON.dump(request.params) + "```")
      end

      private

      def target
        Source.new(room: Lita::Room.find_by_name("tcbot-testing") || "general")
      end

    end

    Lita.register_handler(Mailgun)
  end
end
