module Api
  class AuctionsController < ApplicationController
    def index
      data = AuctionsQuery.new(type: :started).perform
      render json: data, each_serializer: ::Api::Collections::AuctionSerializer
    end

    def update
      result = Auctions::Assigner.new(resource, update_params[:driver_id]).perform

      if result[:errors].present?
        render json: result[:errors], status: :gone
      else
        head :ok
      end
    end

    private

    def resource
      @resource ||= Auction.find(params[:id])
    end

    def update_params
      params.permit(:driver_id)
    end
  end
end
