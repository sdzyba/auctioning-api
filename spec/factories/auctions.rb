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

FactoryBot.define do
  factory :auction do
    price_limit { Faker::Number.decimal(8, 2) }
    step_current 0
    step_limit 5
    status 'scheduled'
    ride_at Time.parse("2017-12-04 15:00 UTC")
    start_at Time.parse("2017-12-04 12:30 UTC")
    end_at Time.parse("2017-12-04 13:00 UTC")
  end
end
