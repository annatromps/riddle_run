class Riddle < ApplicationRecord
  DIFFICULTIES = %w[easy medium hard].freeze

  has_many :attempts, dependent: :restrict_with_error

  validates :question, presence: true
  validates :answer, presence: true
  validates :difficulty, presence: true, inclusion: { in: DIFFICULTIES }
  validates :thinking_seconds, numericality: { only_integer: true, greater_than: 0 }

  scope :published, -> { where(published: true) }
  scope :by_difficulty, ->(level) { where(difficulty: level) }
end
