TwilioTest::Application.routes.draw do
  root to: 'root#root'
  resources :phone_calls, only: [] do
    post :jabberwocky

    post :fallback, on: :collection
    post :connect, on: :collection
    post :fetch_pin, on: :collection
    post :save_recording, on: :member
    post :save_outcome, on: :member
  end
end
