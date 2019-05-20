require 'delivery_methods/slack/delivery_method_base'
require 'json'
require 'uri'

class Slack::MessageDeliveryMethod < Slack::DeliveryMethodBase
  def deliver!(message)
    attachments = [JSON.parse(message.body.to_s)]
    channel = self.settings[:channel]
    
    client = Slack::Web::Client.new(token: self.settings[:api_token])
    client.chat_postMessage(channel: channel, attachments: attachments, as_user: true)
  end
end
