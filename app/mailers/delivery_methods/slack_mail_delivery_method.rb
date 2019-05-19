class SlackMailDeliveryMethod
  attr_accessor :settings

  def initialize(value)
    self.settings = value
  end

  def deliver!(mail)
    attachments = [to_attachment(mail)]
    channel = self.settings[:channel]

    client = Slack::Web::Client.new(token: self.settings[:api_token])
    client.chat_postMessage(channel: channel, text: attachments, as_user: true)
  end

  private

  def to_attachment(mail)
    {
      title: mail.subject,
      text: mail.body.to_s,
    }
  end
end