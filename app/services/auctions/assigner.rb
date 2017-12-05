module Auctions
  class Assigner
    ASSIGNED_ERROR = "Already assigned".freeze

    attr_reader :driver_id, :auction
    private     :driver_id, :auction

    def initialize(auction, driver_id)
      @auction   = auction
      @driver_id = driver_id
    end

    def perform
      auction.with_lock do
        return { errors: [ASSIGNED_ERROR] } if auction.assigned?
        auction.assign_driver(driver_id)
      end
      result
    end

    private

    def result
      if auction.valid?
        { data: auction }
      else
        { errors: auction.errors.full_messages }
      end
    end
  end
end
