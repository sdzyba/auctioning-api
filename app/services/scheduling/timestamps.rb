module Scheduling
  class Timestamps
    DRIVERS_ACTIVE_FROM = 8
    DRIVERS_ACTIVE_TO   = 22
    ONE_DAY             = 1

    attr_reader :from, :from_sec, :to, :to_sec, :middle_sec

    def initialize(ride_at)
      @from = round_time(Time.current)
      @to   = round_time(ride_at - 1.hour)
      adjust
      load_timestamps
    end

    private

    def adjust
      days_diff = to.yday - from.yday

      if days_diff == ONE_DAY
        adjust_next_day
      elsif days_diff > ONE_DAY && to.hour > DRIVERS_ACTIVE_FROM
        defer_from(days_diff.days)
      elsif days_diff > ONE_DAY
        defer_from((days_diff - ONE_DAY).days)
      end
    end

    def adjust_next_day
      defer_from(ONE_DAY.day) if to.hour > DRIVERS_ACTIVE_FROM
      active_to               if to.hour >= DRIVERS_ACTIVE_TO
    end

    def load_timestamps
      @from_sec   = from.to_i
      @to_sec     = to.to_i
      @middle_sec = from_sec + (to_sec - from_sec) / Const::DEFAULT_DIVISION
      @middle_sec += middle_sec % Const::DEFAULT_STEP
    end

    def defer_from(days)
      @from = (from + days).change(hour: DRIVERS_ACTIVE_FROM, min: 0)
    end

    def active_to
      @to = to.change(hour: DRIVERS_ACTIVE_TO, min: 0)
    end

    def round_time(time, seconds = Const::DEFAULT_STEP)
      Time.zone.at((time.to_f / seconds).floor * seconds)
    end
  end
end
