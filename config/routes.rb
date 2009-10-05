ActionController::Routing::Routes.draw do |map|
  map.resources :general_ledgers
  map.resources :accounts, 
                :only=>[:create, :update, :show] do |acct|
    acct.resources :receipts
    acct.resources :invoices
  end

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
