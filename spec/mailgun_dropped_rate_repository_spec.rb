require 'lita/mailgun_dropped_rate_repository'

describe Lita::MailgunDroppedRateRepository do
  let(:redis) { double(Redis::Namespace) }
  let(:repository) { Lita::MailgunDroppedRateRepository.new(redis) }

  before do
    allow(redis).to receive(:rpush)
    allow(redis).to receive(:ltrim)
    allow(redis).to receive(:lrange)
    allow(redis).to receive(:expire)
  end

  describe "#record" do
    before do
      allow(Time).to receive(:now) { Time.utc(2016, 6, 19, 13, 05, 59) }
    end

    context "with event: delivered" do
      it "returns true" do
        expect(
          repository.record("user@example.com", :delivered)
        ).to eq true
      end

      it "stores the event in redis" do
        repository.record("user@example.com", :delivered)
        expect(redis).to have_received(:rpush).with(
          "events-example.com",
          "{\"event\":\"delivered\",\"domain\":\"example.com\",\"recipient\":\"user@example.com\",\"at\":1466341559}"
        )
      end

      it "trims the list" do
        repository.record("user@example.com", :delivered)
        expect(redis).to have_received(:ltrim).with("events-example.com", -50, -1)
      end

      it "sets the list expiry" do
        repository.record("user@example.com", :delivered)
        expect(redis).to have_received(:expire).with("events-example.com", 1209600) # two weeks
      end
    end

    context "with event: dropped" do
      it "returns true" do
        expect(
          repository.record("user@example.com", :dropped)
        ).to eq true
      end

      it "stores the event in redis" do
        repository.record("user@example.com", :dropped)
        expect(redis).to have_received(:rpush).with(
          "events-example.com",
          "{\"event\":\"dropped\",\"domain\":\"example.com\",\"recipient\":\"user@example.com\",\"at\":1466341559}"
        )
      end
    end
    context "with event: foo" do
      it "returns false" do
        expect(
          repository.record("user@example.com", :foo)
        ).to eq false
      end
      it "does not store the event in redis" do
        repository.record("user@example.com", :foo)
        expect(redis).to_not have_received(:rpush)
      end

      it "does not trim the list" do
        repository.record("user@example.com", :foo)
        expect(redis).to_not have_received(:ltrim)
      end

      it "sets the list expiry" do
        repository.record("user@example.com", :foo)
        expect(redis).to_not have_received(:expire)
      end
    end
  end
  describe "#dropped_rate" do
    let(:result) { repository.dropped_rate("example.com") }

    before do
      allow(redis).to receive(:lrange).with("events-example.com", 0, 49).and_return(stored_events)
    end

    context "when the requested domain has 4 events" do
      let(:stored_events) {
        [
          JSON.dump(event: "delivered", domain: "example.com", recipient: "user@example.com", at: Time.now.to_i),
          JSON.dump(event: "dropped", domain: "example.com", recipient: "user2@example.com", at: Time.now.to_i),
          JSON.dump(event: "delivered", domain: "example.com", recipient: "user@example.com", at: Time.now.to_i),
          JSON.dump(event: "delivered", domain: "example.com", recipient: "user@example.com", at: Time.now.to_i),
        ]
      }

      it "sets the domain" do
        expect(result.domain).to eq("example.com")
      end

      it "sets the uniq dropped_count" do
        expect(result.uniq_dropped).to eq(1)
      end

      it "sets the uniq addresses count" do
        expect(result.uniq_addresses).to eq(2)
      end


      it "sets the total_count" do
        expect(result.total).to eq(4)
      end

      it "includes the dropped rate" do
        expect(result.dropped_rate).to eq(BigDecimal.new("50.0"))
      end
    end

    context "when the requested domain has 20 events" do
      let(:stored_events) {
        [
          JSON.dump(event: "delivered", domain: "example.com", recipient: "user@example.com", at: Time.now.to_i),
        ] * 20
      }

      it "sets the domain" do
        expect(result.domain).to eq("example.com")
      end

      it "sets the uniq dropped_count" do
        expect(result.uniq_dropped).to eq(0)
      end

      it "sets the uniq_addresses count" do
        expect(result.uniq_addresses).to eq(1)
      end

      it "sets the total_count" do
        expect(result.total).to eq(20)
      end

      it "includes the dropped rate" do
        expect(result.dropped_rate).to eq(0)
      end
    end

    context "when the requested domain has 2 recent events and 1 old event" do
      let(:eight_days) { 60 * 60 * 24 * 8 }
      let(:stored_events) {
        [
          JSON.dump(event: "delivered", domain: "example.com", recipient: "user@example.com", at: Time.now.to_i - eight_days),
          JSON.dump(event: "dropped", domain: "example.com", recipient: "user@example.com", at: Time.now.to_i),
          JSON.dump(event: "delivered", domain: "example.com", recipient: "user2@example.com", at: Time.now.to_i),
        ]
      }

      it "sets the domain" do
        expect(result.domain).to eq("example.com")
      end

      it "sets the uniq dropped_count" do
        expect(result.uniq_dropped).to eq(1)
      end

      it "sets the uniq_addresses count" do
        expect(result.uniq_addresses).to eq(2)
      end

      it "sets the total_count" do
        expect(result.total).to eq(2)
      end

      it "includes the dropped rate" do
        expect(result.dropped_rate).to eq(BigDecimal.new("50.0"))
      end
    end
  end
end
