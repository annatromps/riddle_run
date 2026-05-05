class Run < ApplicationRecord
  DIFFICULTIES = (Riddle::DIFFICULTIES + ["any"]).freeze

  has_many :attempts, -> { order(:position) }, dependent: :destroy
  has_many :riddles, through: :attempts

  before_validation :set_session_token, on: :create

  validates :difficulty, presence: true, inclusion: { in: DIFFICULTIES }
  validates :riddle_count, numericality: { only_integer: true, greater_than: 0 }
  validates :session_token, presence: true, uniqueness: true
  validates :started_at, presence: true

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

  def set_session_token
    self.session_token = SecureRandom.urlsafe_base64(16)
    self.started_at ||= Time.current
  end
end
