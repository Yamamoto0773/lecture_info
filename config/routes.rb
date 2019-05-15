Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'slack/send_helloworld' => 'slack#send_helloworld'
  get 'slack/send_lecture_info' => 'slack#send_lecture_info'

end
