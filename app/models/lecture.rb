class Lecture < ApplicationRecord
  extend Enumerize

  DEPARTMENT_NAME = {
    general: '一般科', M: '機械工学科', E: '電気電子工学科', S: '電子制御工学科', J: '電子情報工学科', C: '環境都市工学科', all: '全クラス' 
  }

  enumerize :department, in: [:general, :M, :E, :S, :J, :C, :all]

  attr_reader :department

  validate :lecture_cannot_be_double_booking

  after_initialize :set_virtual_attributes
  
  def canceled_on=(time_range)
    self.canceled_from = time_range.begin
    self.canceled_to = time_range.end
  end

  def canceled_on
    self.canceled_from..self.canceled_to
  end

  def canceled_on?
    canceled_from?
  end

  def supplemented_on=(time_range)
    self.supplemented_from = time_range.begin
    self.supplemented_to = time_range.end
  end

  def supplemented_on
    self.supplemented_from..self.supplemented_to
  end
  
  def supplemented_on?
    supplemented_from?
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
  end
end
