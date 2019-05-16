require 'open-uri'
require 'nokogiri'
require 'nkf'

class SlackController < ApplicationController
  def send_helloworld
    client = Slack::Web::Client.new

    client.chat_postMessage(channel: '#develop', text: 'Hello World', as_user: true)

    render plain: 'hello world'
  end

  def send_lecture_info
    url = 'http://www.nagano-nct.ac.jp/current/cancel_info_5th.php'
    doc = Nokogiri::HTML(open(url))

    table_headers = ['休講日', '補講日', '科目名', '教室', '学科', '教員', '備考']
    table_keys = [:canceled_on, :supplemented_on, :subject_and_class, :room, :department, :staff, :remarks]

    doc.css('.cancel').each { |node|
      table = Nokogiri::HTML(node.to_xhtml)

      # 全角英数字を半角英数字，全角スペースを半角スペース，半角カナを全角カナに変換
      # さらに先頭と末尾の空白を除去
      table_values = table.css('td').map { |node| 
        NKF.nkf('-wZ1X' ,node.content).strip
      }
    
      # 補講日と休講日が逆になっているテーブルが存在する
      unless table.at_css('th').content == table_headers[0]
        tmp = table_values[0].dup
        table_values[0] = table_values[1]
        table_values[1] = tmp
      end

      table_hash = Hash[*[table_keys[0...table_values.size], table_values].transpose.flatten]
      lecture = Lecture.new(table_hash)
      lecture.save!

      break
    }

    message = ''
    
    # client = Slack::Web::Client.new
    # client.chat_postMessage(channel: '#develop', text: message, as_user: true)

    render plain: message
  end

end