# == Schema Information
#
# Table name: drivers
#
#  id         :integer          not null, primary key
#  status     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Driver < ApplicationRecord
end
