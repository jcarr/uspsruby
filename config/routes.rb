Usps::Application.routes.draw do
  get "home/index"
  root :to => "home#index"

#  get "tracking/index"
  match "track" => "tracking#index"
#  resource :tracking
end
