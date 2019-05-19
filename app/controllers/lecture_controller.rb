class LectureController < ApplicationController
  def send_helloworld
    ret = LectureMailer.new_info.deliver_now
    render plain: ret
  end

  def new
    render 'slack/new'
  end

  def send_lecture_info
    before_time = Time.zone.now
    
    lecture = Scraping::Lecture.new(file_params)
    lecture.scrape_from_file

    created = Lecture.where(created_at: before_time..Time.zone.now)
    updated = Lecture.where(updated_at: before_time..Time.zone.now)

    # slackのメッセージレイアウトの都合上，1件ずつ送信
    created.each { |info| LectureMailer.new_info(info).deliver_now }
    updated.each { |info| LectureMailer.update_info(info).deliver_now }

    message = ''
    render plain: message
  end

  private

  def file_params
    params.permit(:file)
  end

end