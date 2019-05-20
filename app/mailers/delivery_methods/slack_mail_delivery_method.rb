require 'json'
require 'uri'

class SlackMailDeliveryMethod
  attr_accessor :settings

  def initialize(value)
    self.settings = value
  end

  def deliver!(mail)
    attachments = [JSON.parse(mail.body.to_s)]
    channel = self.settings[:channel]
    
    client = Slack::Web::Client.new(token: self.settings[:api_token])
    client.chat_postMessage(channel: channel, attachments: attachments, as_user: true)
  end
end
