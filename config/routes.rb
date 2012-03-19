Iac::Application.routes.draw do

  ### Admin Namespace
  namespace :admin do
    root :to => "contests#index"
    resources :contests, :except => [:new, :create] do
      resources :c_results, :only => [:index, :show]
    end
    resources :contests do
      member do 
        get 'recompute'
      end
    end
    resources :manny_synchs, :only => [:index, :destroy]
    resources :members, :only => [:index, :edit, :update, :show]
    resources :failures, :only => [:index, :show, :destroy]
    post "members/merge_preview"
    post "members/merge"
  end

  ### Leaders namespace
  namespace :leaders do
    root :to => "contests#index"
    get 'judges/:year', :action => :judges
    get 'judges', :action => :judges
  end

  ### Default namespace
  root :to => "contests#index"

  get "pages/notes"

  resources :contests, :only => [:index, :show]

  resources :pilots, :only => [:index, :show] do
    resources :scores, :only => [:show]
  end

  resources :judges, :only => [:index, :show]

  resources :flights, :only => [:show]

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all routes lay out with "rake routes"

end
