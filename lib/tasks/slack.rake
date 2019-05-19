namespace :slack do
  desc "slackにメッセージを送ります"
  task send_lecture_info: :environment do
    session = ActionDispatch::Integration::Session.new(Rails.application)
    session.get "/lecture/send_lecture_info"
  end
end
