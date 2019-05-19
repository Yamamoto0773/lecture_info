class LectureMailer < ApplicationMailer
  def new_info(lectures)
    mail subject: '新しい休講/補講情報'
  end
end
