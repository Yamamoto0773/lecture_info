namespace :slack do
  desc 'send message to slack channnel configured env variable, and \'message\' is optional, \'hello world\' in defalut.'
  task :send_message, [:message] do |task, args|
    message = args[:message] || 'hello world'

    client = Slack::Web::Client.new(token: ENV['SLACK_API_TOKEN'])
    p client.chat_postMessage(channel: ENV['SLACK_DEFAULT_CHANNEL'], text: message, as_user: true)
  end
end
