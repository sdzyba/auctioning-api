# just an example, it's not used in application
module Auctions
  class DynamicResolver
    attr_reader :ride_at, :start_at_limit, :current_time, :delay_step
    private     :ride_at, :start_at_limit, :current_time, :delay_step

    def initialize(ride_at)
      @ride_at = Time.zone.parse(ride_at)
      @start_at_limit = round(@ride_at - 1.hour)
      @current_time = round(Time.current)
    end

    def perform
      auc = Auction.new(
        price_current: (price * 0.1).round(2),
        price_limit: price,
        step_current: 0,
        step_limit: 5,
        status: "scheduled",
        ride_at: ride_at,
        created_at: Time.current
      )
      grouped_auctions = Auction.scheduled.where("start_at >= ?", current_time).order(:ride_at).group_by { |a| a.ride_at - 1.hour }.presence || Hash.new([])
      grouped_auctions[ride_at - 1.hour] = (grouped_auctions[ride_at - 1.hour] << auc).sort_by(&:ride_at)

      schedule_start = current_time
      Sidekiq::ScheduledSet.new.clear

      grouped_auctions.each do |limit_start_at, auctions|
        delay = get_delay((limit_start_at.to_i - schedule_start.to_i), auctions.count)

        auctions.sort_by(&:created_at).each do |a|
          a.update(start_at: schedule_start, end_at: schedule_start + 30.minutes)
          schedule_start += delay
          StartAuctionWorker.perform_at(schedule_start, a.id)
        end
      end
      auc
    end

    private

    def get_delay(seconds_available, auctions_count, current_step = DEFAULT_STEP)
      steps_available = seconds_available / current_step
      steps_available >= auctions_count ? current_step : get_delay(seconds_available, auctions_count, current_step / 2)
    end

    def round(time, seconds = 60)
      Time.zone.at((time.to_f / seconds).floor * seconds)
    end
  end
end
