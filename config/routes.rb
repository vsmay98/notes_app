Rails.application.routes.draw do

  resources :notes do 
    collection do
      post :share_with_user
      get :all_notes
    end
  end
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  authenticated :user do
    root 'notes#index', as: 'authenticated_root'
  end
  devise_scope :user do
    root 'devise/sessions#new'
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
end