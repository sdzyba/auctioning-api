module Api
  module Collections
    class AuctionSerializer < ActiveModel::Serializer
      attributes :id, :price_current, :next_step_at
    end
  end
end
