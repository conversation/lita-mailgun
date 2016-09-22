require "lita"
require "lita/mailgun_message"
require "base64"

module Lita
  module Handlers
    # Check each incoming email from mailgun and if it's a DMARC report, print the details
    class MailgunDmarcReporter < Handler

      config :channel_name

      on :mailgun_incoming, :monitor_message

      def monitor_message(payload)
        message = payload[:message]

        msg_summary = [
          "[mailgun] incoming message",
          "from: #{message.from}",
          "recipient: #{message.recipient}",
          "subject: #{message.subject}",
          "body_plain: #{message.body_plain}",
          "attachment_count: #{message.attachment_count}"
        ].join("\n")
        robot.send_message(target, msg_summary)
        if message.attachment_count > 0
          first_attachment = message.attachment(1)
          robot.send_message(target, "first attachment contents (base64) (#{first_attachment[:filename]})")
          robot.send_message(target, Base64.encode64(first_attachment[:tempfile].read))
        end
      end

      private

      def target
        Source.new(room: Lita::Room.find_by_name(config.channel_name) || "general")
      end

    end

    Lita.register_handler(MailgunDmarcReporter)
  end
end
