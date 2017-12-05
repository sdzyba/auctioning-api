require "rails_helper"

RSpec.describe Auctions::Assigner do
  describe "#perform" do
    context "when subsequent calls" do
      let(:auction)  { create(:auction) }
      let(:driver_1) { create(:driver) }
      let(:driver_2) { create(:driver) }

      before { auction.start! }

      it "assignes the auction only once" do
        described_class.new(auction, driver_1.id).perform
        expect(described_class.new(auction, driver_2.id).perform).to eq(errors: ["Already assigned"])
      end
    end
  end
end
