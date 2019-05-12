class SlackController < ApplicationController
  def send_helloworld
    client = Slack::Web::Client.new

    client.auth_test
    client.chat_postMessage(channel: '#develop', text: 'Hello World', as_user: true)

    render plain: 'hello world'
  end
end