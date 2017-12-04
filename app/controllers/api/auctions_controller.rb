module Api
  class AuctionsController < ApplicationController
    def index
      render json: Auction.started, each_serializer: ::Api::Collections::AuctionSerializer
    end

    def update
      result = Auctions::Updater.new(resource, update_params[:driver_id]).perform

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
