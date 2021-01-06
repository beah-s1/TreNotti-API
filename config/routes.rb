Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  scope :api do
    scope :auth do
      post 'issue-key', to: 'authorization#generate_token'
    end
    
    scope :device do
      post '', to: 'device#update'
    end
    
    scope :railway do
      get '', to: 'railway#get'
      post '', to: 'railway#update'
    end
    
    scope :health do
      get 'db', to: 'application#health_db'
    end
  end
end
