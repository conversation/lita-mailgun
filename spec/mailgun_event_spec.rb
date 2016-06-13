require 'lita/mailgun_event'
require 'json'

describe Lita::MailgunEvent do
  let(:delivered_path) { File.join(File.dirname(__FILE__), "fixtures", "delivered.json")}
  let(:delivered_data) { JSON.load(File.read(delivered_path)) }
  let(:delivered_event) { Lita::MailgunEvent.new(delivered_data)}
  let(:dropped_path) { File.join(File.dirname(__FILE__), "fixtures", "dropped.json")}
  let(:dropped_data) { JSON.load(File.read(dropped_path)) }
  let(:dropped_event) { Lita::MailgunEvent.new(dropped_data)}

  describe '.name' do
    context 'for a delivered event' do
      it "returns the correct value" do
        expect(delivered_event.name).to eq("delivered")
      end
    end
    context 'for a dropped event' do
      it "returns the correct value" do
        expect(dropped_event.name).to eq("dropped")
      end
    end
  end

  describe '.recipient' do
    context 'for a delivered event' do
      it "returns the correct value" do
        expect(delivered_event.recipient).to eq("alice@example.com")
      end
    end
    context 'for a dropped event' do
      it "returns the correct value" do
        expect(dropped_event.recipient).to eq("alice@example.com")
      end
    end
  end

  describe '.recipient_domain' do
    context 'for a delivered event' do
      it "returns the correct value" do
        expect(delivered_event.recipient_domain).to eq("example.com")
      end
    end
    context 'for a dropped event' do
      it "returns the correct value" do
        expect(dropped_event.recipient_domain).to eq("example.com")
      end
    end
  end
end
