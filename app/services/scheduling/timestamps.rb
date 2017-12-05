module Scheduling
  class Timestamps
    DRIVERS_ACTIVE_FROM = 8
    DRIVERS_ACTIVE_TO   = 22
    ONE_DAY             = 1

    attr_reader :time_from, :time_from_sec, :time_to, :time_to_sec, :time_middle_sec

    def initialize(ride_at)
      @time_from = round_time(Time.current)
      @time_to   = round_time(ride_at - 1.hour)
      adjust
      load_timestamps
    end

    private

    def adjust
      days_diff = time_to.yday - time_from.yday

      if days_diff == ONE_DAY
        adjust_next_day
      elsif days_diff > ONE_DAY && time_to.hour > DRIVERS_ACTIVE_FROM
        defer_time_from(days_diff.days)
      elsif days_diff > ONE_DAY
        defer_time_from((days_diff - ONE_DAY).days)
      end
    end

    def adjust_next_day
      defer_time_from(ONE_DAY.day) if time_to.hour > DRIVERS_ACTIVE_FROM
      active_time_to               if time_to.hour >= DRIVERS_ACTIVE_TO
    end

    def load_timestamps
      @time_from_sec   = time_from.to_i
      @time_to_sec     = time_to.to_i
      @time_middle_sec = time_from_sec + (time_to_sec - time_from_sec) / Const::DEFAULT_DIVISION
      @time_middle_sec += time_middle_sec % Const::DEFAULT_STEP
    end

    def defer_time_from(days)
      @time_from = (time_from + days).change(hour: DRIVERS_ACTIVE_FROM, min: 0)
    end

    def active_time_to
      @time_to = time_to.change(hour: DRIVERS_ACTIVE_TO, min: 0)
    end

    def round_time(time, seconds = Const::DEFAULT_STEP)
      Time.zone.at((time.to_f / seconds).floor * seconds)
    end
  end
end
