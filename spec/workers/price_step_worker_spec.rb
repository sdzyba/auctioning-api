require "rails_helper"

RSpec.describe PriceStepWorker, type: :worker do
  describe "#perform" do
    subject { described_class.new.perform(auction.id) }

    let(:price_limit)   { 100 }
    let(:price_initial) { price_limit * 0.1 }
    let(:auction) do
      create(
        :auction,
        step_limit: 3,
        step_current: step_current,
        price_limit: price_limit,
        price_current: price_initial
      )
    end

    before { allow(PriceStepWorker).to receive(:perform_at) }

    context "when auction already assigned to a driver" do
      let(:step_current) { 1 }

      before do
        allow(Auction).to receive(:find).with(auction.id).and_return(auction)
        expect(auction).to receive(:assigned?).and_return(true)
      end

      it "does nothing" do
        expect { subject }.to_not(change { auction.reload.price_current })
      end
    end

    context "when it is a first step" do
      let(:step_current) { 1 }
      let(:price_after)  { 40 } # 10 + (90 * 1/3)

      it "increases the price" do
        expect { subject }.to change { auction.reload.price_current }.from(price_initial).to(price_after)
      end
    end

    context "when it is a second step" do
      let(:step_current) { 2 }
      let(:price_after)  { 70 } # 10 + (90 * 2/3)

      it "increases the price" do
        expect { subject }.to change { auction.reload.price_current }.from(price_initial).to(price_after)
      end
    end

    context "when it is a third step" do
      let(:step_current) { 3 }
      let(:price_after)  { 100 } # 10 + (90 * 3/3)

      it "increases the price" do
        expect { subject }.to change { auction.reload.price_current }.from(price_initial).to(price_after)
      end
    end

    context "when it is a last step" do
      let(:step_current) { 4 }

      before { auction.start! }

      it "does not change the price" do
        expect { subject }.to_not(change { auction.reload.price_current })
      end

      it "finishes the auction" do
        expect { subject }.to change { auction.reload.status }.from("started").to("finished")
      end
    end
  end
end
