class LectureController < ApplicationController
  # def send_helloworld
  #   ret = LectureMailer.new_info.deliver_now
  #   render plain: ret
  # end

  # def new
  #   render 'slack/new'
  # end

  def index
    render plain: 'lecture_info'
  end

  def send_lecture_info
    before_time = Time.zone.now
    url = ENV['SCRAPE_URL']
    class_name = ENV['TARGET_CLASS_NAME']

    lecture = Scraping::Lecture.new(url: url)
    lecture.scrape_from_url

    created = Lecture.where(class_name: class_name, created_at: before_time..Time.zone.now)
    updated = Lecture.where(class_name: class_name, updated_at: before_time..Time.zone.now)

    updated = updated.reject { |i| i.created_at == i.updated_at }

    # slackのメッセージレイアウトの都合上，1件ずつ送信
    created.each { |info| LectureMailer.new_info(info).deliver_now }
    updated.each { |info| LectureMailer.update_info(info).deliver_now }

    message = ''
    render plain: message
  end

  private

  # def file_params
  #   params.permit(:file)
  # end

end