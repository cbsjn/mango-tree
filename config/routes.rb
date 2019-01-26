Rails.application.routes.draw do
  get 'mappings/index'

  get 'mappings/create'

  get 'mappings/update'

  get 'mappings/edit'

  get 'mappings/destroy'

  get 'cloudbeds/oauth_callback'

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
  #resources :quick_books
  resources :customers do
    collection do
      get 'sync_to_quickbook'
    end
  end
  resources :sales_receipts do
    collection do
      get 'sync_to_quickbook'
    end
  end
  resources :sales_receipt_details
  resources :mappings do
    collection do
      get 'change_dropdown_values'
      get 'mapping_list'
    end
  end
  get 'quick_books/authenticate'
  get 'quick_books/oauth_callback'
  get 'cloudbeds/oauth_callback'
end
