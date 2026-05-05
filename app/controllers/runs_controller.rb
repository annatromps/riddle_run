class RunsController < ApplicationController
  layout "runner"

  before_action :set_run, only: [:show, :complete]

  def new
  end

  def create
    question_style = params[:question_style].presence_in(Run::QUESTION_STYLES) || "word_puzzles"

    pool = case question_style
           when "cryptic" then Riddle.published.where(category: "cryptic")
           when "mix"     then Riddle.published
           else                Riddle.published.where(category: Run::WORD_CATEGORIES)
           end
    riddles = pool.order(Arel.sql("RANDOM()")).limit(Run::PUZZLES_PER_RUN).to_a

    if riddles.empty?
      redirect_to new_run_path, alert: "No puzzles available yet." and return
    end

    @run = Run.new(
      question_style:     question_style,
      audio_enabled:      params[:audio_enabled] == "1",
      timed:              params[:timed] == "1",
      seconds_per_puzzle: params[:seconds_per_puzzle].to_i.clamp(10, 90),
      auto_advance:       params[:auto_advance] == "1"
    )

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
