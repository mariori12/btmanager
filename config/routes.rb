Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'body_temperatures#index'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  namespace :admin do
    resources :users

    get '/temperatures', to: 'export_body_temperatures#index'
    get '/temperatures/export', to: 'export_body_temperatures#export'

    get '/export_and_import_csv', to: 'export_and_import_csv#index'
    get '/export_and_import_csv/export', to: 'export_and_import_csv#export'
    post '/export_and_import_csv/import', to: 'export_and_import_csv#import'
  end
  resources :body_temperatures
end
