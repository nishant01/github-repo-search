Rails.application.routes.draw do
  root 'repositories/index', controller: 'repositories', action: 'index'
  resources :repositories do
    collection do
      post :search
      get :search
    end
  end
end
