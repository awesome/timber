Dummy::Application.routes.draw do
  resources :users

  root to: "posts#index"
  resources :posts
end
