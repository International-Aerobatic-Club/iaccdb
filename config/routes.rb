IAC::Application.routes.draw do

  get 'make_models/index'

  get 'make_models/show'

  ### HQ Namespace
  namespace :hq do
    resources :collegiate, :controller => :collegiate_results, :except => [:index, :new]
    scope :module => :collegiate_results do
      get 'collegiate_teams/:year', :action => :index, :as => :collegiate_teams_index
      get 'collegiate_teams/', :action => :index, :as => :current_collegiate_teams
      get 'collegiate_teams/:year/new', :action => :new, :as => :new_collegiate_team
    end
  end

  ### Admin Namespace
  namespace :admin do
    root :to => "contests#index"
    resources :contests, :except => [:new, :create] do
      resources :jc_results, :only => [:index]
      resources :pc_results, :only => [:index]
    end
    resources :contests do
      member do
        get 'recompute'
      end
    end
    resources :manny_synchs, :only => [:index, :destroy]
    resources :members, :only => [:index, :edit, :update, :show]
    resources :failures, :only => [:index, :show, :destroy]
    resources :data_posts, :only => [:index, :show]
    resources :queues, :only => [:index, :show]
    post "members/merge_preview"
    post "members/merge"
    get 'manny_list',
      :controller => :contests,
      :action => "manny_list"
    get 'manny_synchs/:manny_number/retrieve',
      :controller => :manny_synchs,
      :action => "retrieve",
      :as => 'manny_retrieve'
    get 'manny_synchs/:manny_number/show',
      :controller => :manny_synchs,
      :action => "show",
      :as => 'manny_show'
    post 'jasper',
      :controller => 'jasper',
      :action => 'results'
    get 'data_post/:id/download',
      :controller => :data_posts,
      :action => 'download',
      :as => 'data_post_download'
    get 'data_post/:id/resubmit',
      :controller => :data_posts,
      :action => 'resubmit',
      :as => 'data_post_resubmit'
  end

  ### Leaders namespace
  namespace :leaders do
    root :to => "contests#index"
    get 'judges/:year', :action => :judges, :as => :judges
    get 'judges', :action => :judges, :as => :recent_judges
    get 'regionals/:year', :action => :regionals, :as => :regionals
    get 'regionals', :action => :regionals, :as => :recent_regionals
    get 'soucy/:year', :action => :soucy, :as => :soucy
    get 'soucy', :action => :soucy, :as => :recent_soucy
    get 'collegiate/:year', :action => :collegiate, :as => :collegiate
    get 'collegiate', :action => :collegiate, :as => :recent_collegiate
  end

  ### Default namespace
  root :to => "contests#index"

  get "pages/:title" => 'pages#page_view', :as => 'pages'
  get '/robots.:format' => 'pages#robots'

  resources :contests, except: [:new, :edit]

  resources :pilots, :only => [:index, :show] do
    resources :scores, :only => [:show]
  end

  resources :judges, :only => [:index, :show]

  resources :assistants, :only => [:index, :show]

  resources :pilot_flights, :only => [:show]

  resources :jf_results, :only => [:show]

  get 'judge/:id/cv',
    :controller => :judges,
    :action => :cv,
    :as => 'judge_cv'

  resources :flights, :only => [:show]

  get 'judge/:judge_id/flight/:flight_id',
    :controller => :judges,
    :action => :histograms,
    :as => 'judge_histograms'

  get 'judge/activity',
    :controller => :judges,
    :action => :activity,
    :as => 'recent_judge_activity'

  get 'judge/activity/:year',
    :controller => :judges,
    :action => :activity,
    :as => 'judge_activity'

  namespace :further do
    get 'participation', :action => :participation
    get 'airplanes/:year', :action => :airplane_make_model
    get 'airplanes', :action => :airplane_make_model
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all routes lay out with "rake routes"

end
