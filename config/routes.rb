# Put your extension routes here.
map.resources :google_checkout_notification

map.namespace :admin do |admin|  
admin.resources :orders, :member => {:charge_google_order => :get, :cancel_google_checkout_order => :get}
end
# map.namespace :admin do |admin|
#   admin.resources :whatever
# end  
