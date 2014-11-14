class PagesController < ApplicationController
  def page_view
    render params[:title]
  end

  def robots
  end
end
