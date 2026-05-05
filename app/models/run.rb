class Run < ApplicationRecord
  DIFFICULTIES = (Riddle::DIFFICULTIES + ["any"]).freeze

  has_many :attempts, -> { order(:position) }, dependent: :destroy
  has_many :riddles, through: :attempts

  before_validation :set_defaults, on: :create

  validates :session_token, presence: true, uniqueness: true
  validates :difficulty, inclusion: { in: DIFFICULTIES }
  validates :riddle_count, numericality: { only_integer: true, greater_than: 0 }
  validates :seconds_per_puzzle, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def complete?
    completed_at.present?
  end

  def current_attempt
    attempts.find_by(outcome: nil)
  end

  def score
    attempts.where(outcome: "correct").count
  end

  private

  def set_defaults
    self.session_token = SecureRandom.urlsafe_base64(16)
    self.started_at   ||= Time.current
    self.difficulty   ||= "any"
    self.riddle_count ||= Riddle.published.count
  end
end
