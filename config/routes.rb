Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
  scope :api do
    scope :auth do
      post 'issue-key', to: 'authorization#generate_token'
    end
  end
end
