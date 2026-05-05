class RunsController < ApplicationController
  layout "runner"

  before_action :set_run, only: [:show, :complete]

  def new
  end

  def create
    difficulty = params[:difficulty].presence_in(Run::DIFFICULTIES) || "any"
    riddle_count = params[:riddle_count].to_i.clamp(1, 20)

    scope = Riddle.published
    scope = scope.by_difficulty(difficulty) unless difficulty == "any"
    riddles = scope.order(Arel.sql("RANDOM()")).limit(riddle_count).to_a

    if riddles.empty?
      redirect_to new_run_path, alert: "No riddles available for that difficulty." and return
    end

    @run = Run.new(difficulty: difficulty, riddle_count: riddles.count)

    Run.transaction do
      @run.save!
      riddles.each_with_index do |riddle, i|
        @run.attempts.create!(riddle: riddle, position: i)
      end
    end

    redirect_to @run
  end

  def show
    @attempt = @run.current_attempt
    redirect_to complete_run_path(@run) if @attempt.nil?
  end

  def complete
    @attempts = @run.attempts.includes(:riddle)
  end

  private

  def set_run
    @run = Run.find(params[:id])
  end
end
