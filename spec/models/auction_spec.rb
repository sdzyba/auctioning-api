# == Schema Information
#
# Table name: auctions
#
#  id            :integer          not null, primary key
#  price_current :decimal(10, 2)   not null
#  price_limit   :decimal(10, 2)   not null
#  step_current  :integer          not null
#  step_limit    :integer          not null
#  status        :string           not null
#  ride_at       :datetime         not null
#  start_at      :datetime         not null
#  end_at        :datetime         not null
#  driver_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_auctions_on_driver_id  (driver_id)
#  index_auctions_on_start_at   (start_at) UNIQUE
#

require 'rails_helper'

RSpec.describe Auction, type: :model do
  describe "#next_step_at" do
    let(:start_at) { Time.parse("2017-12-04 12:30 UTC") }
    let(:end_at)   { Time.parse("2017-12-04 13:00 UTC") }
    let(:auction)  { build_stubbed(:auction, step_limit: 3, step_current: 0, start_at: start_at, end_at: end_at) }

    context 'when current step is 0' do
      it "returns auction's start_at time" do
        expect(auction.next_step_at).to eq(auction.start_at)
      end
    end

    context 'when current step is 1' do
      before { auction.step_current += 1}

      it "returns the next time for a first step" do
        expect(auction.next_step_at).to eq(auction.start_at + 10.minutes)
      end
    end

    context 'when current step is 2' do
      before { auction.step_current += 2}

      it "returns the next time for a second step" do
        expect(auction.next_step_at).to eq(auction.start_at + 20.minutes)
      end
    end

    context 'when current step is 3' do
      before { auction.step_current += 3}

      it "returns the next time equal to end_at" do
        expect(auction.next_step_at).to eq(auction.end_at)
      end
    end
  end
end
