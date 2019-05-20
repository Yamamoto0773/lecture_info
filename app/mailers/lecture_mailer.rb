require 'json'

class LectureMailer < ApplicationMailer
  default delivery_method: :slack_message

  def new_info(lecture)
    @lecture_json = to_attachment_json(
      lecture,
      fallback: '新しい休講補講情報です',
      color: 'good',
      pretext: '新しい休講補講情報です',
    )

    mail
  end

  def update_info(lecture)
    @lecture_json = to_attachment_json(
      lecture,
      fallback: '休講補講情報が更新されました',
      color: 'warning',
      pretext: '休講補講情報が更新されました',
    )

    mail
  end

  def canceled_reminder(lecture)
    message = "明日の#{lecture.subject}は休講です"

    @lecture_json = {
      text: message,
    }.to_json

    mail
  end

  def supplemented_reminder(lecture)
    koma_beg = (lecture.supplemented_section_beg + 1)/2
    koma_end = (lecture.supplemented_section_end + 1)/2

    message = ""
    message << "明日は#{lecture.subject}の補講が"
    message << "#{koma_beg}"
    message << "〜#{koma_end}" if koma_beg != koma_end
    message << "コマ目にあります"

    @lecture_json = {
      text: message,
    }.to_json

    mail
  end

  private

  def to_attachment_json(lecture, options = {})
    hash = {}

    hash.merge!(options)

    field_arr = []
    field_arr << {
      title: '科目',
      value: lecture.subject,
      short: false
    }
    field_arr << {
      title: '休講日',
      value: date_format(lecture.canceled_on, lecture.canceled_section_beg, lecture.canceled_section_end),
      short: true
    }
    field_arr << {
      title: '補講日',
      value: date_format(lecture.supplemented_on, lecture.supplemented_section_beg, lecture.supplemented_section_end),
      short: true
    }
    if lecture.remarks.present?
      field_arr << { title: '備考', value: lecture.remarks, short: false }
    end
    
    hash.store('fields', field_arr)

    hash.to_json
  end

  def date_format(date, sec_beg, sec_end)
    koma_beg = (sec_beg + 1)/2
    koma_end = (sec_end + 1)/2

    str = ""
    str << I18n.l(date, format: :date)
    str << ' '
    str << "#{koma_beg}"
    str << "〜#{koma_end}" if koma_beg != koma_end
    str << 'コマ目'
  end
end
