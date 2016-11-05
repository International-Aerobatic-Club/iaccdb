class JfResultsController < ApplicationController
  def show
    @jf_result = JfResult.find(params[:id])
    @judge_grades = JfResult::JudgeGrades.new(@jf_result)
  end
end
