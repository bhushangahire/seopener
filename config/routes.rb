ActionController::Routing::Routes.draw do |map|

  map.namespace :seo do |seo|
    seo.resources :search_terms, { :member=>{:query=>:post, :query_update=>:post} }
  end

end