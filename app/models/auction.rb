# == Schema Information
#
# Table name: auctions
#
#  id            :integer          not null, primary key
#  price_current :decimal(10, 2)   not null
#  price_limit   :decimal(10, 2)   not null
#  step_current  :integer          not null
#  step_limit    :integer          not null
#  status        :string           not null
#  ride_at       :datetime         not null
#  start_at      :datetime         not null
#  end_at        :datetime         not null
#  driver_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_auctions_on_driver_id  (driver_id)
#  index_auctions_on_start_at   (start_at) UNIQUE
#

class Auction < ApplicationRecord
  STATUSES = [
    SCHEDULED = "scheduled".freeze,
    STARTED   = "started".freeze,
    FINISHED  = "finished".freeze,
    ASSIGNED  = "assigned".freeze
  ].freeze

  include AASM

  aasm(:status, whiny_transitions: false) do
    state :scheduled, initial: true
    state :started
    state :assigned
    state :finished

    event :start do
      transitions from: :scheduled, to: :started
    end

    event :assign do
      transitions from: :started, to: :assigned
    end

    event :finish do
      transitions from: :assigned, to: :finished
      transitions from: :started, to: :finished
    end
  end

  belongs_to :driver, required: false

  validates :price_current, presence: true, numericality: { greater_than: 0 }
  validates :price_limit,   presence: true, numericality: { greater_than: 0 }
  validates :step_current,  presence: true, numericality: { only_integer: true }
  validates :step_limit,    presence: true, numericality: { only_integer: true }
  validates :status,        presence: true, inclusion: { in: STATUSES }
  validates :ride_at,       presence: true
  validates :start_at,      presence: true
  validates :end_at,        presence: true
  validates :driver,        presence: true, if: :assigned?

  scope :started,   -> { where(status: STARTED) }
  scope :scheduled, -> { where(status: SCHEDULED) }

  def next_step_at
    start_at + step_length * step_current
  end

  def ended?
    step_current > step_limit
  end

  def next_price_update!
    price_initial = price_limit * Const::PRICE_INITIAL_MULTIPLIER
    price_increase = (price_limit - price_initial) * (step_current.to_f / step_limit)

    update!(price_current: price_initial + price_increase, step_current: step_current + Const::STEP_INCREASE)
  end

  private

  def step_length
    (end_at - start_at) / step_limit
  end
end
