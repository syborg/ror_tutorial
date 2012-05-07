RorTutorial::Application.routes.draw do

  resources :users
  resources :sessions, :only => [:new, :create, :destroy]
  # MME almost all about microposts is done from User pages
  resources :microposts, :only => [:create, :destroy]
  # MME s'habiliten dos rutes per accedir als metodes per crear i destruïr relationships
  resources :relationships, :only => [:create, :destroy]
  # MME ex 11.5.7 add route to show all microposts from one user
  resources :users do
    resources :microposts, :only => :index
  end
  # MME adds following, followers, reply and message actions to users (member implies user id, while collection not)
  # /users/1/following, /users/1/followers ,/users/1/reply, /users/1/message
  resources :users do
    member do
      get :following, :followers, :reply, :message
    end
  end

  # MME adds routes to enable password reminders
  resources :password_reminders, :only => [:new, :create]
  # En comptes de deixar que aquesta ruta sigui la estandar de resources,faig algunes modificacions com el
  # identificar el password_reminder pel token (no per un id))
  match '/password_reminders/:token', :to=>'password_reminders#edit',  # controller#action
                                     :as=>:edit_password_reminder,     # named route
                                     :via=>'get'                       # HTTP method
  # MME adds password action to users
  # PUT /users/:token/password
  match 'users/:token/password',    :to=>'users#password',  # controller#action
                                    :as=>:password_user,    # named route
                                    :via=>'put'             # HTTP method

  # MME adds routes to enable activation_tokens
  resources :activation_tokens, :only => [:new, :create]

  # MME adds activation action to users
  # GET /users/:token/activation
  match 'users/:token/activation',  :to=>'users#activation',  # controller#action
                                    :as=>:activate_user,      # named route
                                    :via=>'get'               # HTTP method

  # MME named routes que simplifiquen les standard (pages/...)
  match '/contact', :to => 'pages#contact'
  match '/about',   :to => 'pages#about'
  match '/help',    :to => 'pages#help'

  #match '/', :to => 'pages#home'
  root :to => 'pages#home'

  match '/signup',  :to => 'users#new'
  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
