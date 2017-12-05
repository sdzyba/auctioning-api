class StartAuctionWorker
  include Sidekiq::Worker

  def perform(auction_id)
    auction = Auction.find(auction_id)
    auction.step_current += Const::STEP_INCREASE
    auction.start
    auction.save!
    AuctionStepWorker.perform_at(auction.next_step_at, auction.id)
  end
end
