require "lita/mailgun_dropped_rate"

describe Lita::Handlers::MailgunDroppedRate, lita_handler: true do
  let(:handler) { Lita::Handlers::MailgunDroppedRate.new(robot) }

  describe "#monitor_event" do
    let(:payload) { {event: event} }
    let(:repository) { instance_double(Lita::MailgunDroppedRateRepository, record: true) }
    let(:result) { Lita::MailgunDroppedRateRepository::DroppedResult.new("example.com", 3, 4) }

    before do
      allow(robot).to receive(:send_message)
      allow(handler).to receive(:repository).and_return(repository)
      allow(repository).to receive(:dropped_rate).and_return(result)
    end

    context "an email was delivered" do
      let(:event) { Lita::MailgunEvent.new("event" => "delivered", "recipient" => "james@example.com") }

      it "records the event and sends a message" do
        handler.monitor_event(event: event)
        expect(repository).to have_received(:record).with("example.com", :delivered)
        expect(robot).to have_received(:send_message).once
      end
    end

    context "an two emails were delivered" do
      let(:event) { Lita::MailgunEvent.new("event" => "delivered", "recipient" => "james@example.com") }

      it "records the event and sends a single message" do
        handler.monitor_event(event: event)
        handler.monitor_event(event: event)
        expect(repository).to have_received(:record).with("example.com", :delivered).twice
        expect(robot).to have_received(:send_message).once
      end
    end
  end
end
