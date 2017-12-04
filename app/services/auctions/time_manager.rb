module Auctions
  class TimeManager
    DRIVERS_ACTIVE_FROM = 8
    DRIVERS_ACTIVE_TO   = 22
    ONE_DAY             = 1

    attr_reader :ride_at, :time_from, :time_to
    private     :ride_at, :time_from, :time_to

    def initialize(ride_at)
      @ride_at      = ride_at
      @time_from    = round_time(Time.current)
      @time_to      = round_time(@ride_at - 1.hour)
    end

    def active_hours
      days_diff = time_to.yday - time_from.yday
      if days_diff == ONE_DAY
        defer_time_from(ONE_DAY.day) if time_to.hour > DRIVERS_ACTIVE_FROM
        active_time_to if time_to.hour >= DRIVERS_ACTIVE_TO
      elsif days_diff > ONE_DAY
        if time_to.hour > DRIVERS_ACTIVE_FROM
          defer_time_from(days_diff.days)
        else
          defer_time_from((days_diff - 1).days)
        end
      end
      timestamps
    end

    private

    def timestamps
      time_from_sec   = time_from.to_i
      time_to_sec     = time_to.to_i
      time_middle_sec = time_from_sec + (time_to_sec - time_from_sec) / Auctions::StartTimeResolver::DEFAULT_DIVISION
      time_middle_sec += time_middle_sec % Auctions::StartTimeResolver::DEFAULT_STEP
      {
        time_from:       time_from,
        time_from_sec:   time_from_sec,
        time_to:         time_to,
        time_to_sec:     time_to_sec,
        time_middle_sec: time_middle_sec
      }
    end

    def defer_time_from(days)
      @time_from = (time_from + days).change(hour: DRIVERS_ACTIVE_FROM, min: 0)
    end

    def active_time_to
      @time_to = time_to.change(hour: DRIVERS_ACTIVE_TO, min: 0)
    end

    def round_time(time, seconds = Auctions::StartTimeResolver::DEFAULT_STEP)
      Time.zone.at((time.to_f / seconds).floor * seconds)
    end
  end
end
