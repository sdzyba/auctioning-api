module Scheduling
  class Resolver
    attr_reader :time
    private     :time

    def initialize(ride_at)
      @time = Scheduling::Timestamps.new(ride_at)
    end

    def perform
      return Time.zone.at(time.time_middle_sec) if occupied_slots.empty?
      result = start_at(
        occupied_slots.select { |start_at| start_at >= time.time_middle_sec },
        occupied_slots.select { |start_at| start_at <= time.time_middle_sec }
      )
      Time.zone.at(result)
    end

    private

    def occupied_slots
      @occupied_slots ||= AuctionsQuery.new(type: :slots, time_from: time.time_from, time_to: time.time_to).perform
    end

    def start_at(occupied_after, occupied_before, step_sec = Const::DEFAULT_STEP)
      after  = available_after(occupied_after, step_sec)
      before = available_before(occupied_before, step_sec)

      if after && before
        after - time.time_middle_sec < time.time_middle_sec - before ? after : before
      elsif !(after || before)
        start_at(occupied_after, occupied_before, step_sec / Const::DEFAULT_DIVISION)
      else
        after || before
      end
    end

    def available_after(occupied_after, step_sec)
      all_after = slots(time.time_to_sec - time.time_middle_sec, step_sec, time.time_middle_sec)
      (all_after - occupied_after).first
    end

    def available_before(occupied_before, step_sec)
      all_before = slots(time.time_middle_sec - time.time_from_sec, step_sec, time.time_from_sec)
      (all_before - occupied_before).last
    end

    def slots(all_seconds, step_sec, begin_value)
      (0..(all_seconds / step_sec)).map { |n| begin_value + n * step_sec }
    end
  end
end
