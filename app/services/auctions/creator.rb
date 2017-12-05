module Auctions
  class Creator
    STEP_INITIAL             = 0
    STEP_LIMIT               = 5
    PRICE_ROUND_PRECISION    = 2
    AUCTION_TIME_LENGTH      = 30.minutes

    attr_reader :price, :ride_at
    private     :price, :ride_at

    def initialize(price, ride_at)
      @price   = price
      @ride_at = Time.zone.parse(ride_at) if ride_at.present?
    end

    def perform
      auction = init_auction

      if auction.valid?
        StartAuctionWorker.perform_at(auction.start_at, auction.id)
        { data: auction }
      else
        { errors: auction.errors.full_messages }
      end
    end

    private

    # rubocop:disable Metrics/MethodLength
    def init_auction
      start_at      = find_start_at
      end_at        = start_at + AUCTION_TIME_LENGTH                                         if start_at.present?
      price_current = (price * Const::PRICE_INITIAL_MULTIPLIER).round(PRICE_ROUND_PRECISION) if price.present?

      Auction.create(
        price_current: price_current,
        price_limit:   price,
        step_current:  STEP_INITIAL,
        step_limit:    STEP_LIMIT,
        ride_at:       ride_at,
        start_at:      start_at,
        end_at:        end_at
      )
    end
    # rubocop:enable Metrics/MethodLength

    def find_start_at
      return if ride_at.blank?
      ::Lock.start_at.with_lock { Scheduling::Resolver.new(ride_at).perform }
    end
  end
end
