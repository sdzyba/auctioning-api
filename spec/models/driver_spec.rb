# == Schema Information
#
# Table name: drivers
#
#  id         :integer          not null, primary key
#  status     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Driver, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
