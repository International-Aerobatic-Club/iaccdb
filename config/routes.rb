Rails.application.routes.draw do

  ### HQ Namespace
  namespace :hq do
    resources :collegiate, controller: :collegiate_results, except: [:index, :new]
    scope module: :collegiate_results do
      get 'collegiate_teams/:year', action: :index, as: :collegiate_teams_index
      get 'collegiate_teams/', action: :index, as: :current_collegiate_teams
      get 'collegiate_teams/:year/new', action: :new, as: :new_collegiate_team
      post 'collegiate_results/recompute/:year', action: :recompute
    end
  end

  ### Admin Namespace
  namespace :admin do
    root to: 'contests#index'
    resources :contests, except: [:new, :create] do
      resources :jc_results, only: [:index]
      resources :pc_results, only: [:index]
    end
    resources :contests do
      member do
        post 'recompute'
      end
    end
    resources :members, only: [:index, :edit, :update, :show]
    resources :failures, only: [:index, :show, :destroy]

    resources :data_posts, only: [:index, :show]
    get 'data_post/:id/download', controller: :data_posts, action: 'download', as: 'data_post_download'
    get 'data_post/:id/resubmit', controller: :data_posts, action: 'resubmit', as: 'data_post_resubmit'

    resources :queues, only: [:index, :show]
    resources :free_program_ks
    post 'members/merge_preview'
    post 'members/merge'
    resources :make_models, only: [:index, :edit, :update]
    post 'make_models/merge_preview'
    post 'make_models/merge'
    post 'jasper', controller: 'jasper', action: 'results'
  end

  ### Leaders namespace
  namespace :leaders do
    root to: 'contests#index'
    get 'chiefs/:year', action: :chiefs, as: :chiefs
    get 'chiefs', action: :chiefs, as: :recent_chiefs
    get 'judges/:year', action: :judges, as: :judges
    get 'judges', action: :judges, as: :recent_judges
    get 'regionals/:year', action: :regionals, as: :regionals
    get 'regionals', action: :regionals, as: :recent_regionals
    get 'soucy/:year', action: :soucy, as: :soucy
    get 'soucy', action: :soucy, as: :recent_soucy
    get 'leo/:year', action: :leo, as: :leo
    get 'leo', action: :leo, as: :recent_leo
    get 'collegiate/:year', action: :collegiate, as: :collegiate
    get 'collegiate', action: :collegiate, as: :recent_collegiate
    get 'pilot_contest_counts/:year', action: :pilot_contest_counts, as: :pilot_contest_counts
    get 'pilot_contest_counts', action: :pilot_contest_counts, as: :recent_pilot_contest_counts
  end

  ### Default namespace
  root to: 'contests#index'

  get 'pages/:title' => 'pages#page_view', as: 'pages'
  get '/robots.:format' => 'pages#robots'

  resources :contests, except: [:new, :edit]

  resources :pilots, only: [:index, :show] do
    resources :scores, only: [:show]
  end

  resources :chiefs, only: [:index, :show]

  resources :judges, only: [:index, :show]

  resources :assistants, only: [:index, :show]

  resources :pilot_flights, only: [:show]

  resources :jf_results, only: [:show]

  resources :make_models, only: [:index, :show]

  resources :live_results, only: [:show]
  get '/last_upload/:id' => 'live_results#last_upload'

  get 'chief/:id/cv', controller: :chiefs, action: :cv, as: 'chief_cv'

  get 'judge/:id/cv', controller: :judges, action: :cv, as: 'judge_cv'

  resources :flights, only: [:show]

  get 'judge/:judge_id/flight/:flight_id', controller: :judges, action: :histograms, as: 'judge_histograms'

  get 'judge/activity', controller: :judges, action: :activity, as: 'recent_judge_activity'

  get 'judge/activity/:year', controller: :judges, action: :activity, as: 'judge_activity'

  namespace :further do
    get 'participation', action: :participation
    get 'airplanes/:year', action: :airplane_make_model
    get 'airplanes', action: :airplane_make_model
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # See how all routes lay out with 'rake routes'

end
