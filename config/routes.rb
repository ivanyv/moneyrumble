ActionController::Routing::Routes.draw do |map|
  map.resources :contacts

  #map.resources :transactions

  map.resources :accounts, :collection => { :dashboard => :get } do |a|
    a.resources :transactions, :collection => { :update_attr => :any }
    a.payments 'transactions', :controller => 'transactions', :action => 'create', :method => :post
    a.deposits 'deposits', :controller => 'transactions', :action => 'create', :method => :post
  end
   
  # Restful Authentication Rewrites
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.forgot_password '/forgot_password', :controller => 'passwords', :action => 'new'
  map.change_password '/change_password/:reset_code', :controller => 'passwords', :action => 'reset'
  map.open_id_complete '/opensession', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.open_id_create '/opencreate', :controller => "users", :action => "create", :requirements => { :method => :get }
  
  # Restful Authentication Resources
  map.resources :users
  map.resources :passwords
  map.resource :session
  
  # Home Page
  map.root :controller => 'accounts', :action => 'dashboard'

  map.connect 'auto_complete_for_contact_name', :controller => 'accounts', :action => 'auto_complete_for_contact_name'
#  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
