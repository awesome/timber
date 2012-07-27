Dummy::Application.routes.draw do


  root to: "posts#index"
  resources :posts
  resources :users do
    get :events, on: :member
  end

end
