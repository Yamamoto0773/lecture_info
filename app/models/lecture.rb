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
  attr_reader :canceled_on
  attr_reader :supplemented_on

  validate :lecture_cannot_be_double_booking

  after_initialize :set_virtual_attributes
  
  # [YYYY, MM, DD, 始まりのコマ, 終わりのコマ]から代入
  def canceled_on=(strings)
    self.canceled_from, self.canceled_to = date_strings_to_duration_time(strings)
  end

  def supplemented_on=(strings)
    self.supplemented_from, self.supplemented_to = date_strings_to_duration_time(strings)
  end

  # すでに同じ講座が登録されているか返します
  def double_booking?
    !double_booked.empty?
  end

  # 同じ講座を返します
  def double_booked # -> array
    lectures = Lecture
      .where(class_name: self.class_name, canceled_from: self.canceled_from)
      .where.not(id: self.id)
  end

  private

  def lecture_cannot_be_double_booking
    errors[:base] << '講座が重複しています' if double_booking?
  end

  def set_virtual_attributes
    @department = :general
    DEPARTMENT_NAME.each { |key, val|
      if self.class_name.include?(key.to_s) || self.class_name.include?(val)
        @department = key
        break
      end
    }

    @canceled_on, @canceled_section_beg, @canceled_section_end = duration_time_to_section(self.canceled_from, self.canceled_to)
    @supplemented_on, @supplemented_section_beg, @supplemented_section_end = duration_time_to_section(self.supplemented_from, self.supplemented_to)
  end

  # [YYYY, MM, DD, 始まりの時限, 終わりの時限]から期間を表すdatetimeを生成
  def date_strings_to_duration_time(date_strings) # -> array[from, to]
    from = Time.zone.strptime(
      date_strings[0..2].join + LECTURE_SCHEDULE[date_strings[3].to_i - 1][:from], '%Y%m%d%H:%M:%S'
    )
    to = Time.zone.strptime(
      date_strings[0..2].join + LECTURE_SCHEDULE[date_strings[4].to_i - 1][:to], '%Y%m%d%H:%M:%S'
    )

    [from, to]
  end

  # 2つのdatetimeから[date, 始まりの時限, 終わりの時限]を生成
  def duration_time_to_section(from, to)
    date = from.to_date
    sec_beg = 0, sec_end = 0

    LECTURE_SCHEDULE.each_with_index { |s, i|
      if s[:from] == from.strftime('%H:%M:%S')
        sec_beg = i and break
      end
    }

    LECTURE_SCHEDULE.each_with_index { |s, i|
      if s[:to] == to.strftime('%H:%M:%S')
        sec_end = i and break
      end
    }

    [date, sec_beg, sec_end]
  end
end
