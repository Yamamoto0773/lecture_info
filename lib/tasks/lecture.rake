namespace :lecture do
  desc 'Scrape the lecture information, then send these messages to Slack channel'
  task scrape_and_send: :environment do
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

    puts "scraping completed! new_info:#{created.size}, updated_info:#{updated.size}"
  end

  desc 'Opening url and send dummy lecture info to Slack (database is not affected)'
  task test_scrape_and_send_dummy: :environment do
    url = ENV['SCRAPE_URL']
    class_name = ENV['TARGET_CLASS_NAME']

    # test for opening url
    lecture = Scraping::Lecture.new(url: url)
    
    created = Lecture.where(class_name: class_name).first
    updated = Lecture.where(class_name: class_name).last

    # slackのメッセージレイアウトの都合上，1件ずつ送信
    LectureMailer.new_info(created).deliver_now
    LectureMailer.update_info(updated).deliver_now

    puts "test finished!"
  end

  desc 'Send reminder'
  task send_reminders: :environment do
    now = Time.zone.now
    class_name = ENV['TARGET_CLASS_NAME']

    canceled = Lecture.where(class_name: class_name, canceled_from: now..now.since(1.days))
    supplemented = Lecture.where(class_name: class_name, supplemented_from: now..now.since(1.days))

    canceled.each { |info| LectureMailer.canceled_reminder(info).deliver_now }
    supplemented.each { |info| LectureMailer.supplemented_reminder(info).deliver_now }

    puts "send reminders canceled_reminders:#{canceled.size} supplemented_reminders:#{supplemented.size}"
  end

  desc 'Send dummy reminder'
  task send_dummy_reminders: :environment do
    now = Time.zone.now
    class_name = ENV['TARGET_CLASS_NAME']

    canceled = Lecture.where(class_name: class_name).first
    supplemented = Lecture.where(class_name: class_name).first

    LectureMailer.canceled_reminder(canceled).deliver_now
    LectureMailer.supplemented_reminder(supplemented).deliver_now

    puts "test finished!"
  end
end
