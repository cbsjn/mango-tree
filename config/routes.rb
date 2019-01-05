Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'login#index'

  resources :login do
    collection do
      post 'sign_up'
      post 'sign_in'
      get 'dashboard'
      get 'sign_out'
    end
  end
end
