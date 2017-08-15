Theschoolcircle::Application.routes.draw do

  get '/home'         , :to => 'pages#home'     
  get '/about'        , :to => 'pages#about'
  get '/coming_soon'  , :to => 'pages#coming_soon'
  get '/help'         , :to => 'pages#help'
  post '/coming_soon'  , :to => 'pages#create_interested_people'
  
  devise_for :users, 
             :controllers => { :registrations => "users/registrations", :sessions=> "users/sessions",:omniauth_callbacks => "users/omniauth_callbacks"}, 
             :path_names => { :sign_in => 'signin', :sign_out => 'signout', :sign_up => 'singup'}
  
  resources :circles, :only=>[:index, :show, :new, :create, :edit] do
     resources :invitations, :controller=>'circles/invitations', :only => [:new, :create, :destroy]
     resources :memberships,  :controller=>'circles/memberships'
  end
  resources :classrooms do
    resources :memberships, :controller=>'classrooms/memberships'
  end  
  resources :documents, :only=>[:index, :show, :destroy]
  resources :families do
    resources :memberships, :controller=>'families/memberships'
  end
  resource  :feed, :only=>[:show]
  resources :groups do
    resources :memberships, :controller=>'groups/memberships'
  end 
  resources :invitations, :except=>[ :show, :edit, :update, :destroy, :index] do
    get 'accept'
    get 'accept_new_user'
  end
  resources :memberships, :only=>[:create, :destroy]
  resources :messages do
    resources :comments, :controller=>'messages/comments'
  end
  resources :user_public_profile, :controller => 'user_public_profiles', :only=>[:show]
  resources :reminders
  resources :schools do
    resources :memberships, :controller=>'schools/memberships'
  end
  devise_scope :user do
    get :welcome_message, :controller=>'users/registrations', :action=>'welcome_message'
  end
  resources :users, :except => [:new, :edit, :index] do
    devise_scope :user do  
      get :post_board, :controller=>'users', :action=>'post_board', :as=>'post_board'
      get :welcome, :controller=>'users', :action=>'welcome', :as=>'welcome'
      resource :account,          :controller => 'users/registrations',   :except=>[:new, :create]
      resources :contacts,        :controller => 'users/contacts',        :only=>[:index, :destroy] do
        collection do
          get 'authenticate'
          get 'authorise'
          get 'import'
        end
      end
      resource  :profile,         :controller => 'users/profiles',        :except=>[:new, :create]
      resources :authentications, :controller => 'users/authentications', :only=>[:destroy]
      resources :circles,         :controller => 'users/circles',         :only=>[:index]
      resources :connections,     :controller => 'users/connections',     :only=>[:index]
      resources :documents,       :controller => 'users/documents',       :only=>[:index, :show, :destroy]
      resources :certificates,     :controller => 'users/certificates',   :only=>[:index, :show]
      collection do
        get 'signup', :controller => 'users/registrations', :action=>'new', :as => "new_registration"
        match 'signup', :controller => 'users/registrations', :action=>'create', :via => :post, :as => "new_registration"
      end
    end
  end
  resources :votes, :only=>[:create, :destroy]  
  resources :zfiles, :only=>[:create, :destroy]
  
  devise_scope :user do 
    
  end
  
  if Rails.env == "development"
    resources :emails, :only=>:index do
       get 'invitation', :controller=>'emails', :action=>'invitation'  
    end
  end
    
  resources :offers
  get 'deal_page', :to=>"offers#show_deal"
  get 'resize_page', :to=>"offers#resize"
  get 'certificate_page', :to=>"offers#certificate"
  get 'account_page', :to=>"offers#account"

  resources :businesses do
    collection do
       get 'signin', :controller=>'businesses', :action=>'signin'
    end   
  end
    
  namespace :api do
    
    # The latest version of the API does NOT have a version number in the URL
    # Clients should use this API since the versioned one are temporary.
    # resources :post, :controller => 'api/v1/post_controller'  
    namespace :v1  do
      resources :messages, :only=>[:create]
      resources :reminders, :only=>[:index]  
      resources :tokens, :only => [:create, :destroy]
    end
  end
  
  root :to => "pages#coming_soon"
  
  
  # Custom HTLM pages for errors. See: http://www.ramblinglabs.com/blog/2012/01/rails-3-1-adding-custom-404-and-500-error-pages
  # These routes are useful for development
  if Rails.env == "development"
    get '/error_404', to: 'errors#error_404'     
    get '/error_500', to: 'errors#error_500'     
  end
  
  
  unless Rails.application.config.consider_all_requests_local
    # the constrains allows the omniauth routes to "go through". With out it the OAuth dace fails.
    match '*not_found', to: 'errors#error_404',:constraints => lambda {|req| ! req.path.starts_with?("/users/auth/") }
  end
  
end






