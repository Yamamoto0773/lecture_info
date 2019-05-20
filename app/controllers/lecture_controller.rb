class LectureController < ApplicationController
  def index
    render plain: 'lecture_info'
  end
end
