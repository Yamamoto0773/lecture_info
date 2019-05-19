class SlackController < ApplicationController
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

    p created = Lecture.where(created_at: before_time..Time.zone.now)
    p updated = Lecture.where(updated_at: before_time..Time.zone.now)

    message = ''
    
    # client = Slack::Web::Client.new
    # client.chat_postMessage(channel: '#develop', text: message, as_user: true)

    render plain: message
  end

  private

  def file_params
    params.permit(:file)
  end

end