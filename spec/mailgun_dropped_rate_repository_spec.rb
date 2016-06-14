require 'lita/mailgun_dropped_rate_repository'

describe Lita::MailgunDroppedRateRepository do
  let(:repository) { Lita::MailgunDroppedRateRepository.new }

  context "with data for a single domain" do
    before do
      repository.record("example.com", :delivered)
      repository.record("example.com", :dropped)
      repository.record("example.com", :delivered)
      repository.record("example.com", :delivered)
    end

    describe "#dropped_rate" do
      let(:result) { repository.dropped_rate("example.com") }

      it "sets the domain" do
        expect(result.domain).to eq("example.com")
      end

      it "sets the dropped count" do
        expect(result.dropped).to eq(1)
      end

      it "sets the total_count" do
        expect(result.total).to eq(4)
      end

      it "includes the dropped rate" do
        expect(result.dropped_rate).to eq(BigDecimal.new("25.0"))
      end
    end
  end
  context "when a single domain records 101 events" do
    before do
      101.times do
        repository.record("example.com", :delivered)
      end
    end
    describe "#dropped_rate" do
      let(:result) { repository.dropped_rate("example.com") }

      it "sets the domain" do
        expect(result.domain).to eq("example.com")
      end

      it "sets the dropped count" do
        expect(result.dropped).to eq(0)
      end

      it "sets the total_count" do
        expect(result.total).to eq(100)
      end

      it "includes the dropped rate" do
        expect(result.dropped_rate).to eq(0)
      end
    end
  end
end
