module Admin
  module Resources
    class AuctionSerializer < ActiveModel::Serializer
      attributes :id, :ride_at, :start_at, :price_limit, :price_current
    end
  end
end
