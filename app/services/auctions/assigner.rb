module Auctions
  class Assigner
    ERROR = "Already assigned".freeze

    attr_reader :driver_id, :auction
    private     :driver_id, :auction

    def initialize(auction, driver_id)
      @auction   = auction
      @driver_id = driver_id
    end

    def perform
      auction.with_lock do
        return { errors: [ERROR] } if auction.assigned?
        assign
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

    def assign
      auction.assign
      auction.driver_id = driver_id
      auction.save!
    end
  end
end
