# == Schema Information
#
# Table name: locks
#
#  id         :integer          not null, primary key
#  entity     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_locks_on_entity  (entity) UNIQUE
#

require 'rails_helper'

RSpec.describe Lock, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
