class AuctionStepWorker
  include Sidekiq::Worker

  def perform(auction_id)
    auction = Auction.find(auction_id)
    return if auction.assigned?

    if auction.ended?
      auction.finish!
    else
      auction.next_price_update!
      AuctionStepWorker.perform_at(auction.next_step_at, auction.id)
    end
  end
end
