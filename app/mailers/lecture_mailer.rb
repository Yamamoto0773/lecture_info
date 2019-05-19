require 'json'

class LectureMailer < ApplicationMailer
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
      value: "#{lecture.canceled_on} #{(lecture.canceled_section_beg + 1)/2}-#{(lecture.canceled_section_end + 1)/2}コマ目",
      short: true
    }
    field_arr << {
      title: '補講日',
      value: "#{lecture.supplemented_on} #{(lecture.supplemented_section_beg + 1)/2}-#{(lecture.supplemented_section_end + 1)/2}コマ目",
      short: true
    }
    if lecture.remarks.present?
      field_arr << { title: '備考', value: lecture.remarks, short: false }
    end
    
    hash.store('fields', field_arr)

    hash.to_json
  end
end