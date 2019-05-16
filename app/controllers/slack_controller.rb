require 'open-uri'
require 'nokogiri'

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

    hash = {}
    message = ''

    doc.css('.cancel').each { |node|
      table = Nokogiri::HTML(node.to_xhtml)
      cancel_at = []
      supplemented_at = []
      subject = ''
      class_name = ''

      table.css('td').each_with_index { |cell, i|
        case i
        when 0
          cancel_at = str_to_date(cell.content)
        when 1
          supplemented_at = str_to_date(cell.content)
        when 2
          subject = cell.content.slice(0...cell.content.index('['))
          class_name = substr_range(cell.content, '[', ']')
        end
      }

      unless table.at_css('th').content == table_headers[0]
        tmp = cancel_at.dup
        cancel_at = supplemented_at
        supplemented_at = tmp
      end

      p cancel_at
      p supplemented_at
      p subject
      p class_name
    }
    
    # client = Slack::Web::Client.new
    # client.chat_postMessage(channel: '#develop', text: message, as_user: true)

    render plain: message
  end

end