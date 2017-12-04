class PriceStepWorker
  include Sidekiq::Worker

  def perform(auction_id)
    auction = Auction.find(auction_id)
    return if auction.assigned?

    if auction.step_current > auction.step_limit
      auction.finish!
    else
      price_initial = auction.price_limit * 0.1
      price_increase = (auction.price_limit - price_initial) * (auction.step_current.to_f / auction.step_limit)

      auction.update!(
        price_current: price_initial + price_increase,
        step_current: auction.step_current + 1
      )
      PriceStepWorker.perform_at(auction.next_step_at, auction.id)
    end
  end
end
