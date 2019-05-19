Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'lecture/send_helloworld' => 'lecture#send_helloworld'
  get 'lecture/new' => 'lecture#new'
  post 'lecture/send_lecture_info' => 'lecture#send_lecture_info'

end
