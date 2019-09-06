require 'nkf'

class ScrapeLecture::BaseService < ApplicationService
  def initialize
    @time_table = Settings.lecture.time_table
  end

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

      params = to_model_params(table_keys, table_values)

      lecture = Lecture.new(params)

      has_booked = lecture.double_booked
      if has_booked.empty?
        lecture.save
      else
        has_booked[0].update!(params)
      end
    }
  end

  private

  def to_duration_time(date_string) # -> Range(from..to)
    num_strings = date_string.split(/\D+/)

    from = Time.zone.strptime(
      num_strings[0..2].join + @time_table[num_strings[3].to_i - 1][:from], '%Y%m%d%H:%M:%S'
    )
    to = Time.zone.strptime(
      num_strings[0..2].join + @time_table[num_strings[4].to_i - 1][:to], '%Y%m%d%H:%M:%S'
    )
    rescue
      nil..nil
    else
    from..to
  end

  def to_model_params(table_keys, table_values)
    table_values[0] = to_duration_time(table_values[0])
    table_values[1] = to_duration_time(table_values[1])

    # 科目名とクラス名を分割し，別々の要素にする
    # 学科の要素を削除する
    subject, class_name = table_values[2].split(/[\[\]]/)
    table_values[2] = subject
    table_values.insert(3, class_name)
    table_values.delete_at(5)

    table_hash = {}
    table_keys.zip(table_values).each { |key, val| table_hash.store(key, val) }
    
    table_hash
  end
end
