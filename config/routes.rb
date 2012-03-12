Ontohub::Application.routes.draw do
  
  devise_for :users, :controllers => { :registrations => "users/registrations" }
  
  namespace :admin do
    resources :teams, :only => :index
    resources :users
  end

  resources :ontologies do
    resources :entities, :only => :index
    resources :axioms,   :only => :index
    resources :permissions, :only => [:index, :create, :update, :destroy]
  end
  
  resources :teams do
    resources :team_users, :only => [:index, :create, :update, :destroy], :path => 'users'
  end
  
  get 'autocomplete' => 'autocomplete#index'

# root :to => 'home#show'
  root :to => 'ontologies#index'

end
