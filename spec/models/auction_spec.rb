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

require 'rails_helper'

RSpec.describe Auction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
