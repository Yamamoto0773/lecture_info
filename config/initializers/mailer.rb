require 'delivery_methods/slack_mail_delivery_method'

ActionMailer::Base.add_delivery_method(:slack, SlackMailDeliveryMethod)

ActionMailer::Base.slack_settings = {
  api_token: ENV['SLACK_API_TOKEN'],
  channel: ENV['SLACK_DEFAULT_CHANNEL'],
}
