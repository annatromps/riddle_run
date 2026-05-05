class Admin::RiddlesController < Admin::BaseController
  before_action :set_riddle, only: [:edit, :update, :destroy]

  def index
    @riddles = Riddle.order(:difficulty, :created_at)
  end

  def new
    @riddle = Riddle.new(thinking_seconds: 30, published: true)
  end

  def create
    @riddle = Riddle.new(riddle_params)
    if @riddle.save
      redirect_to admin_riddles_path, notice: "Riddle created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @riddle.update(riddle_params)
      redirect_to admin_riddles_path, notice: "Riddle updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @riddle.destroy
    redirect_to admin_riddles_path, notice: "Riddle deleted."
  end

  private

  def set_riddle
    @riddle = Riddle.find(params[:id])
  end

  def riddle_params
    params.require(:riddle).permit(
      :question, :answer, :hint, :difficulty,
      :category, :thinking_seconds, :published
    )
  end
end
