module Scheduling
  class Timestamps
    DRIVERS_ACTIVE_FROM = 8
    DRIVERS_ACTIVE_TO   = 22
    ONE_DAY             = 1

    attr_reader :from, :to

    def initialize(ride_at)
      @from = round_time(Time.current)
      @to   = round_time(ride_at - 1.hour)
      adjust
    end

    def from_sec
      @from_sec ||= from.to_i
    end

    def to_sec
      @to_sec ||= to.to_i
    end

    def middle_sec
      return @middle_sec if @middle_sec
      @middle_sec = from_sec + (to_sec - from_sec) / Const::DEFAULT_DIVISION
      @middle_sec += middle_sec % Const::DEFAULT_STEP
    end

    private

    def adjust
      days_diff = to.yday - from.yday

      if days_diff.zero?
        adjust_current_day
      elsif days_diff == ONE_DAY
        adjust_next_day
      elsif days_diff > ONE_DAY
        days_adjustment = to.hour > DRIVERS_ACTIVE_FROM ? days_diff.days : (days_diff - ONE_DAY).days
        defer_from(days_adjustment)
      end
    end

    def adjust_current_day
      defer_from if from.hour < DRIVERS_ACTIVE_FROM && to.hour > DRIVERS_ACTIVE_FROM
    end

    def adjust_next_day
      defer_from(ONE_DAY.day) if to.hour > DRIVERS_ACTIVE_FROM
      active_to               if to.hour >= DRIVERS_ACTIVE_TO
    end

    def defer_from(days = 0)
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
