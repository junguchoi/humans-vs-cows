class QuestionsController < ApplicationController
  def index
    @question = Question.last

    # Add conditional to check if survey has already been taken
    # or if survey is still in progress before creating a new survey round
    if session[:survey_round_id] && @question.id == session[:question_id]
      redirect_to "/facts"
    elsif session[:survey_round_id]
      @question = Question.find_by_id(session[:question_id])
    else
      @question = Question.first
      session[:survey_round_id] = SurveyRound.create().id
      session[:question_id] = @question.id
    end

    @choices = @question.choices
    @survey_round_id = session[:survey_round_id]
  end

  def update
    question = Question.find_by_id(params[:id])

    if question.update_attributes(question_params)
      # send back status 200
      head status: 200
    else
      # send back status 500
      head status: 500
    end
  end

  def next
    question = Question.find_by_id(session[:question_id])
    next_question = {
      question: question,
      choices: question.choices,
      surveyRoundId: session[:survey_round_id]
    }

    render json: next_question
  end

  def restart
    session[:survey_round_id] = nil
    redirect_to "/questions"
  end

  def fetch
    questions = {questions: Question.all}

    render json: questions
  end

  private
    def question_params
      params.require(:question).permit(:text)
    end
end
