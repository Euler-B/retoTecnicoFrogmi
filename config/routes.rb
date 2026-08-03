Rails.application.routes.draw do
  scope '/v1' do
    resources :sismos, only: [:index] do
      resources :reports, only: [:create]
    end
  end
end
