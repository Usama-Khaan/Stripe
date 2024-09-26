Rails.application.routes.draw do
  root "books#index"

  resources :books do
    resources :charges, only: %i[new create]
  end
end
