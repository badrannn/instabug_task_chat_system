require "sidekiq/web"
require "sidekiq-scheduler/web"

Rails.application.routes.draw do
  resources :applications, param: :token, only: [:create, :show] do
    patch :update, on: :member
    resources :chats, only: [:index, :show, :create], param: :number do
      resources :messages, only: [:index, :show, :create], param: :number do
        get :search, on: :collection 
      end
    end
  end
  mount Sidekiq::Web => "/sidekiq"
end
