Rails.application.routes.draw do
  scope '/v1' do
    resources :sismos, only: [:index] do
      get 'stats', on: :collection
      resources :reports, only: [:create]
    end
    resources :devices, only: %i[index create destroy]
  end
end
