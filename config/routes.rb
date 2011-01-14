Iac::Application.routes.draw do
  resources :contests, :only => [:index, :show]
  root :to => "contests#index"

  resources :pilots, :only => [:index, :show] do
    resources :scores, :only => [:show]
  end

  resources :judges, :only => [:index, :show]

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all routes lay out with "rake routes"

end
