ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.

  map.connect '', :controller => "wiki", :action=> "index"
  
  # Morpheme controller
  map.connect '/morpheme/list/:order_by', 
      :controller => 'morpheme',
      :action => 'list',
      :order_by => 'freq' # default value

  map.connect '/morpheme',
      :controller => 'morpheme',
      :action => 'list',
      :order_by => 'freq'

  # Frame controller
  map.connect '/frame/list/:order_by', 
      :controller => 'frame',
      :action => 'list',
      :order_by => 'freq' # default value

  map.connect '/frame',
      :controller => 'frame',
      :action => 'list',
      :order_by => 'freq'

  # Primitive controller
  map.connect '/primitive',
      :controller => 'primitive',
      :action => 'list'

  # Phrase controller
  map.connect '/phrase/list/:order_by', 
      :controller => 'phrase',
      :action => 'list',
      :order_by => 'freq' # default value
      
  map.connect '/phrase',
      :controller => 'phrase',
      :action => 'list'      
      
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
