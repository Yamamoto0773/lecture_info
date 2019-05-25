require 'json'

class LectureMailer < ApplicationMailer
  default delivery_method: :slack_message

  def new_info(lecture)
    @attachments_json = {
      fallback: '新しい休講補講情報です',
      color: 'good',
      pretext: '新しい休講補講情報です',
      fields: to_attachment_fields(lecture),
    }.to_json

    mail
  end

  def update_info(lecture)
    @attachments_json = {
      fallback: '休講補講情報が更新されました',
      color: 'warning',
      pretext: '休講補講情報が更新されました',
      fields: to_attachment_fields(lecture)
    }.to_json

    mail
  end

  def canceled_reminder(lecture)
    message = "明日の#{lecture.subject}は休講です"
    message << "\n(#{lecture.remarks})" if lecture.remarks.present?

    @attachments_json = {
      text: message,
    }.to_json

    mail
  end

  def supplemented_reminder(lecture)
    cell = to_cell_range(lecture.supplemented_on)

    message = ""
    message << "明日は#{lecture.subject}の補講が"
    message << "#{cell.begin}"
    message << "〜#{cell.end}" if cell.begin != cell.end
    message << "コマ目にあります"
    message << "\n(#{lecture.remarks})" if lecture.remarks.present?

    @attachments_json = {
      text: message,
    }.to_json

    mail
  end

  private

  def to_attachment_fields(lecture)
    field_arr = []
    field_arr << {
      title: '科目',
      value: lecture.subject,
      short: false
    }
    field_arr << {
      title: '休講日',
      value: lecture.canceled_on? ? date_format(lecture.canceled_on) : '未定',
      short: true
    }
    field_arr << {
      title: '補講日',
      value: lecture.supplemented_on? ? date_format(lecture.supplemented_on) : '未定',
      short: true
    }

    if lecture.remarks.present?
      field_arr << {
        title: '備考',
        value: lecture.remarks,
        short: false
      }
    end
    
    field_arr
  end
end
