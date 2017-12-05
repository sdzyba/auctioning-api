class AuctionStepWorker
  include Sidekiq::Worker

  def perform(auction_id)
    auction = Auction.find(auction_id)
    return if auction.assigned?

    if auction.step_current > auction.step_limit
      auction.finish!
    else
      update(auction)
      AuctionStepWorker.perform_at(auction.next_step_at, auction.id)
    end
  end

  private

  def update(auction)
    price_initial = auction.price_limit * Const::PRICE_INITIAL_MULTIPLIER
    price_increase = (auction.price_limit - price_initial) * (auction.step_current.to_f / auction.step_limit)

    auction.update!(
      price_current: price_initial + price_increase,
      step_current: auction.step_current + Const::STEP_INCREASE
    )
  end
end
