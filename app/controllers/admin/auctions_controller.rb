module Admin
  class AuctionsController < ApplicationController
    def create
      result = Auctions::Creator.new(create_params[:price], create_params[:ride_at]).perform

      if result[:errors].present?
        render json: result[:errors], status: :unprocessable_entity
      else
        render json: result[:data], serializer: ::Admin::Resources::AuctionSerializer
      end
    end

    private

    def create_params
      params.require(:auction).permit(:ride_at, :price)
    end
  end
end
