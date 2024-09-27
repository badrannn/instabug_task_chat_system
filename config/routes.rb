Rails.application.routes.draw do
  resources :applications, param: :token, only: [ :create, :show, :update, :index ] do
    resources :chats, only: [:index,:show], param: :number do
      resources :messages, only: [:index,:show]
    end
  end
end
