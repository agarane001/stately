Rails.application.routes.draw do
  devise_for :users

  # Public routes
  root "home#index"

  # Authenticated routes
  authenticate :user do
    resources :books do
      collection do
        get "available"
        get "borrowed"
        get "reserved"
      end
    end

    resources :members do
      member do
        get "loans"
        get "reservations"
      end
    end

    resources :book_loans do
      member do
        patch "return"
        patch "extend"
      end
    end

    resources :reservations do
      member do
        patch "cancel"
        patch "fulfill"
      end
    end

    resources :authors do
      collection do
        get "with_books"
      end
    end

    resources :categories do
      collection do
        get "with_books"
      end
    end

    get "dashboard", to: "dashboard#index"
  end
end
