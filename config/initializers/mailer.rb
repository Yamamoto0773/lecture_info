require 'delivery_methods/slack/message_delivery_method'

ActionMailer::Base.add_delivery_method(:slack_message, Slack::MessageDeliveryMethod)

ActionMailer::Base.slack_message_settings = {
  api_token: ENV['SLACK_API_TOKEN'],
  channel: ENV['SLACK_DEFAULT_CHANNEL'],
}
