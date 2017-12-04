module Auctions
  class StartTimeResolver
    DEFAULT_DIVISION = 2
    DEFAULT_STEP     = 60
    QUERY            = "start_at >= ? AND start_at <= ?".freeze

    attr_reader :time_manager, :time
    private     :time_manager, :time

    def initialize(ride_at)
      @time_manager = Auctions::TimeManager.new(ride_at)
      @time = time_manager.active_hours
    end

    def perform
      find_start_at
    end

    private

    def find_start_at
      return Time.zone.at(time[:time_middle_sec]) if occupied_slots.empty?
      after_middle  = occupied_slots.select { |start_at| start_at >= time[:time_middle_sec] }
      before_middle = occupied_slots.select { |start_at| start_at <= time[:time_middle_sec] }.reverse
      Time.zone.at(start_time(after_middle, before_middle))
    end

    def occupied_slots
      @occupied_slots ||= Auction.scheduled
                                 .where(QUERY, time[:time_from], time[:time_to])
                                 .order(:start_at)
                                 .pluck(:start_at)
                                 .map(&:to_i)
    end

    def start_time(after_middle, before_middle, step_sec = DEFAULT_STEP)
      after  = slot_after(after_middle, step_sec)
      before = slot_before(before_middle, step_sec)

      if after && before
        after - time[:time_middle_sec] < time[:time_middle_sec] - before ? after : before
      elsif after.nil? && before.nil?
        start_time(after_middle, before_middle, step_sec / DEFAULT_DIVISION)
      else
        after || before
      end
    end

    def slot_after(slots, step_sec)
      return time[:time_middle_sec] + step_sec if slots.empty?
      slots.append(slots.last) if slots.size.even?

      slot = available_slot(slots, step_sec, true)
      slot if ((time[:time_middle_sec] + step_sec)..time[:time_to_sec]).cover? slot
    end

    def slot_before(slots, step_sec)
      return time[:time_middle_sec] - step_sec if slots.empty?
      slots.append(slots.last) if slots.size.even?

      slot = available_slot(slots, step_sec, false)
      slot if (time[:time_from_sec]...time[:time_middle_sec]).cover? slot
    end

    def available_slot(slots, step_sec, after)
      slots.each_slice(DEFAULT_DIVISION) do |a, b|
        slot_a = after ? step_increase(a, step_sec) : step_decrease(a, step_sec)
        break slot_a if b.nil? || slot_a != b && slots.exclude?(slot_a)

        slot_b = after ? step_decrease(b, step_sec) : step_increase(b, step_sec)
        break slot_b if slot_b != a && slots.exclude?(slot_b)
      end
    end

    def step_increase(value, step)
      prev_value = value + step
      prev_value += prev_value % step
    end

    def step_decrease(value, step)
      prev_value = value - step
      prev_value -= prev_value % step
    end
  end
end
