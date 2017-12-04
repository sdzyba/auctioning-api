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

class Lock < ApplicationRecord
  START_AT = 'start_at'.freeze
  ASSIGN   = 'assign'.freeze

  scope :start_at, -> { find_by(entity: START_AT) }
  scope :assign,   -> { find_by(entity: ASSIGN) }
end
