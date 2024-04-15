Rails.application.routes.draw do
  scope "/v1" do
    resources :sismos, only: [:index]
  end
end
