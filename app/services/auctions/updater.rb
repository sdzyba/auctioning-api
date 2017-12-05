module Auctions
  class Updater
    MESSAGE = "Already assigned".freeze

    attr_reader :driver_id, :auction
    private     :driver_id, :auction

    def initialize(auction, driver_id)
      @auction   = auction
      @driver_id = driver_id
    end

    def perform
      Lock.assign.with_lock do
        return { errors: [MESSAGE] } if auction.assigned?
        auction.driver_id = driver_id
        auction.assign

        if auction.save
          { data: auction }
        else
          { errors: auction.errors.full_messages }
        end
      end
    end
  end
end
