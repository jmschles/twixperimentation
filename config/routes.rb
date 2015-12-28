TwilioTest::Application.routes.draw do
  root to: 'root#root'
  resource :twilio, only: [] do
    post :voice
  end
end
