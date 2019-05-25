class ApplicationMailer < ActionMailer::Base
  include ApplicationHelper

  # default from: 'from@example.com'
  layout 'mailer'
end
