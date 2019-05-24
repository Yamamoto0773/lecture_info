require 'open-uri'
require 'nokogiri'
require 'nkf'

class Scraping::Lecture
  include ActiveModel::Model

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

  attr_accessor :file, :url

  def scrape_from_file
    doc = Nokogiri::HTML(File.open(@file.path))
    scrape(doc)
  end

  def scrape_from_url
    doc = Nokogiri::HTML(open(@url))
    scrape(doc)
  end

  private

  def scrape(doc)
    table_headers = ['休講日', '補講日', '科目名', '教室', '学科', '教員', '備考']
    table_keys = [:canceled_on, :supplemented_on, :subject, :class_name, :room, :staff, :remarks]

    doc.css('.cancel').each { |node|
      table = Nokogiri::HTML(node.to_xhtml)

      # 全角英数字を半角英数字，全角スペースを半角スペース，半角カナを全角カナに変換
      # さらに先頭と末尾の空白を除去
      table_values = table.css('td').map { |node| 
        NKF.nkf('-wZ1X', node.content).strip
      }
    
      # 補講日と休講日が逆になっているテーブルが存在する
      unless table.at_css('th').content == table_headers[0]
        tmp = table_values[0].dup
        table_values[0] = table_values[1]
        table_values[1] = tmp
      end

      table_values[0] = to_duration_time(split_date_str(table_values[0]))
      table_values[1] = to_duration_time(split_date_str(table_values[1]))

      # 科目名とクラス名を分割し，別々の要素にする
      # 学科の要素を削除する
      subject, class_name = table_values[2].split(/[\[\]]/)
      table_values[2] = subject
      table_values.insert(3, class_name)
      table_values.delete_at(5)

      table_hash = {}
      table_keys.zip(table_values).each { |key, val| table_hash.store(key, val) }
      
      lecture = ::Lecture.new(table_hash)

      has_booked = lecture.double_booked
      if has_booked.empty?
        lecture.save
      else
        has_booked[0].update!(table_hash)
      end
    }
  end

  # YYYY月MM月DD日[n-m時限]を[YYYY, MM, DD, n, m]に分割します
  def split_date_str(str)
    str.split(/\D+/)
  end

  def to_ordinal(time)
    LECTURE_SCHEDULE.each_with_index { |s, i|
      if s[:to] == to.strftime('%H:%M:%S')
        sec_end = i+1 and break
      end
    }
  end

  # [YYYY, MM, DD, 始まりの時限, 終わりの時限]から期間を表すdatetimeを生成
  def to_duration_time(date_strings) # -> Range(from..to)
    from = Time.zone.strptime(
      date_strings[0..2].join + LECTURE_SCHEDULE[date_strings[3].to_i - 1][:from], '%Y%m%d%H:%M:%S'
    )
    to = Time.zone.strptime(
      date_strings[0..2].join + LECTURE_SCHEDULE[date_strings[4].to_i - 1][:to], '%Y%m%d%H:%M:%S'
    )
    rescue
      nil..nil
    else

    from..to
  end
end
