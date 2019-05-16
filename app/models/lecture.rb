class Lecture < ApplicationRecord
  extend Enumerize

  LECTURE_SCHEDULE = [
    { from: '08:50:00', to: '09:34:59' }, # first
    { from: '09:35:00', to: '10:19:59' }, # second
    { from: '10:30:00', to: '11:14:59' }, # third
    { from: '11:15:00', to: '11:59:59' }, # forth
    { from: '12:50:00', to: '13:34:59' }, # fifth
    { from: '13:35:00', to: '14:19:59' }, # sixth
    { from: '14:30:00', to: '15:14:59' }, # seventh
    { from: '15:15:00', to: '15:59:59' }, # eighth
  ]

  DEPARTMENT_NAME = {
    general: '一般科', M: '機械工学科', E: '電気電子工学科', S: '電子制御工学科', J: '電子情報工学科', C: '環境都市工学科', all: '全クラス' 
  }

  enumerize :department, in: [:general, :M, :E, :S, :J, :C, :all]

  attr_reader :department
  attr_reader :canceled_section_beg
  attr_reader :canceled_section_end
  attr_reader :supplemented_section_beg
  attr_reader :supplemented_section_end

  validate :lecture_cannot_be_double_booking
  
  def department=(str)
    # ダミーカラム
    # 学科の欄からは正確な学科の情報が取得できないため，
    # 科目名の欄のクラスから，推測します
  end

  def subject_and_class=(str)
    index = str.index('[')
    self.subject = str[0...index]
    self.class_name = substr_range(str, '[', ']')

    @department = :general
    DEPARTMENT_NAME.each { |key, val|
      if self.class_name.include?(key.to_s) || self.class_name.include?(val)
        @department = key
        break
      end
    }
    
  end

  def canceled_on=(str)
    date_strings = perse_date_str(str)
    @canceled_section_beg = date_strings[1].to_i
    @canceled_section_end = date_strings[2].to_i

    self.canceled_from = Time.zone.strptime(
      date_strings[0] + LECTURE_SCHEDULE[@canceled_section_beg - 1][:from], '%Y年%m月%d日%H:%M:%S'
    )
    self.canceled_to = Time.zone.strptime(
      date_strings[0] + LECTURE_SCHEDULE[@canceled_section_end - 1][:to], '%Y年%m月%d日%H:%M:%S'
    )
  end

  def supplemented_on=(str)
    date_strings = perse_date_str(str)
    @supplemented_section_beg = date_strings[1].to_i
    @supplemented_section_end = date_strings[2].to_i

    self.supplemented_from = Time.zone.strptime(
      date_strings[0] + LECTURE_SCHEDULE[@supplemented_section_beg - 1][:from], '%Y年%m月%d日%H:%M:%S'
    )
    self.supplemented_to = Time.zone.strptime(
      date_strings[0] + LECTURE_SCHEDULE[@supplemented_section_end - 1][:to], '%Y年%m月%d日%H:%M:%S'
    )
  end

  private

  # YYYY月MM月DD日[n-m時限]を[YYYY月MM月DD日, n, m]に分割します
  def perse_date_str(str)
    end_index = str.index('[')
    date_str = str.slice(0...end_index)
    section_str = substr_range(str, '[', ']')

    end_index = section_str.index('-')
    section_beg = section_str.slice(0...end_index)
    beg_index = end_index + 1;
    end_index = section_str.index('時')
    section_end = section_str.slice(beg_index...end_index)

    [date_str, section_beg, section_end]
  end

  def substr_range(str, beg_ch, end_ch)
    beg_index = str.index(beg_ch) + 1
    end_index = str.index(end_ch)
    str.slice(beg_index...end_index)
  end

  def lecture_cannot_be_double_booking
    lectures = Lecture
      .where(class_name: self.class_name)
      .where(canceled_from: self.canceled_from)

    errors[:base] << '講座が重複しています' unless lectures.empty?
  end
end
