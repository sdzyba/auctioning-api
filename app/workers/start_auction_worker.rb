class StartAuctionWorker
  include Sidekiq::Worker

  def perform(auction_id)
    auction = Auction.find(auction_id)
    auction.start!
    PriceStepWorker.perform_at(auction.next_step_at, auction.id)
  end
end
