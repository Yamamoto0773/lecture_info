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

    keys = ['休講日', '補講日', '科目名', '教室', '学科', '教員', '備考']

    message = ''

    doc.css('.cancel').each { |node|
      table = Nokogiri::HTML(node.to_xhtml)
      table.css('td').each { |cell|
        p cell.content
      }
    }
    
    # client = Slack::Web::Client.new
    # client.chat_postMessage(channel: '#develop', text: message, as_user: true)

    render plain: message
  end

end