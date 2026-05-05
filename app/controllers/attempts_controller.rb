class AttemptsController < ApplicationController
  def update
    @attempt = Attempt.find(params[:id])
    @run = @attempt.run

    outcome = params[:outcome].presence_in(Attempt::OUTCOMES)
    @attempt.update!(outcome: outcome)

    redirect_to @run
  end
end
