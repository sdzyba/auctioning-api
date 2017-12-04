class AuctionsQuery
  SLOTS_WHERE = "start_at >= ? AND start_at <= ?".freeze

  attr_reader :options
  private     :options

  def initialize(*args)
    @options = args
  end

  def perform
    case options[:type]
    when :slots
      slots
    when :started
      Auction.started
    else
      [] # instead of returning empty array we can raise exception here
    end
  end

  private

  def slots
    Auction.scheduled
           .where(SLOTS_WHERE, options[:time_from], options[:time_to])
           .order(:start_at)
           .pluck(:start_at)
           .map(&:to_i)
  end
end
