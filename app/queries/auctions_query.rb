class AuctionsQuery
  INVALID_PARAM = "Invalid query type".freeze

  attr_reader :options
  private     :options

  def initialize(options)
    @options = options
  end

  def perform
    case options[:type]
    when :slots
      slots
    when :started
      Auction.started
    else
      raise ArgumentError, INVALID_PARAM
    end
  end

  private

  def slots
    Auction.where(start_at: options[:time_from]..options[:time_to])
           .order(:start_at)
           .pluck(:start_at)
           .map(&:to_i)
  end
end
