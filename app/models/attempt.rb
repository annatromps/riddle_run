class Attempt < ApplicationRecord
  OUTCOMES = %w[correct wrong revealed skipped].freeze

  belongs_to :run
  belongs_to :riddle

  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :outcome, inclusion: { in: OUTCOMES }, allow_nil: true

  scope :completed, -> { where.not(outcome: nil) }
end
