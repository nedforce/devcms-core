ActionController::Routing::Routes.draw do |map|
  map.connect '/:controller/:action'
  map.connect '/:controller/:action/:id'
  map.connect '/:controller/:action/:id.:format'

  # URL aliasing route, should be defined last. Case-insensitive regexp using //i does not work!
  # Sync ID requirements to node.rb!
  map.connect '/:id.:format', :controller => '_aliased', :action => 'show', :requirements => { :id => /[a-zA-Z0-9_\-]((\/)?[a-zA-Z0-9_\-])*/ }
  map.aliased '/:id/:action', :controller => '_aliased', :action => 'show', :requirements => { :id => /[a-zA-Z0-9_\-]((\/)?[a-zA-Z0-9_\-])*/ }
end