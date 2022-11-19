Rails.application.routes.draw do
  resources :users, only: %i[new create]
  resources :questions do
    resources :answers, only: %i[create destroy edit update]
  end
 
  
  root 'pages#index'
end
