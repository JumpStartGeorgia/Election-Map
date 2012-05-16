ElectionMap::Application.routes.draw do

  devise_for :users

  root :to => "root#index"

  match '/export', :to => 'root#export', :as => :export, :via => :post, :defaults => {:format => 'svg'}
  match '/routing_error', :to => 'root#routing_error'
  match "/:locale" => "root#index", via: :get, :as => :root
  match '/:locale/admin', :to => 'root#admin', :as => :admin, :via => :get
  match '/:locale/clear_cache', :to => 'root#clear_cache', :as => :clear_cache, :via => :get
  match '/:locale/shape/:id', :to => 'root#shape', :as => :shape, :via => :get, :defaults => {:format => 'json'}
  match '/:locale/children_shapes/:parent_id(/:parent_shape_clickable(/:indicator_id))', :to => 'root#children_shapes', :as => :children_shapes, :via => :get, :defaults => {:format => 'json'}
  match '/:locale/download/:event_id/:shape_type_id/:shape_id(/:indicator_id)', :to => 'root#download', :as => :download_data, :via => :get

  scope "/:locale" do
    resources :locales
  end

  scope "/:locale" do
    resources :data do
			collection do
        get :upload
        post :upload
        get :export
			end
		end
  end

  scope "/:locale" do
    resources :indicator_scales do
  		collection do
        get :upload
        post :upload
        get :export
  		end
    end
  end
  
  scope "/:locale" do
    resources :indicators do
			collection do
        get :upload
        post :upload
        get :export
        get :download
        post :download
        get :change_name
        post :change_name
        get :export_name_change
			end
		end
  end
  
  scope "/:locale" do
    resources :events
  end
  
  scope "/:locale" do
    resources :event_types
  end
  
  scope "/:locale" do
    resources :pages
  end
  match '/:locale/pages/view/:name(/:layout)', :to => 'pages#view', :as => :view_pages, :via => :get

  scope "/:locale" do
    resources :shapes do
			collection do
        get :upload
        post :upload
        get :export
			end
		end
  end
  
  scope "/:locale" do
    resources :shape_types
  end

	# Catch unroutable paths and send to the routing error handler
	match '*a', :to => 'root#routing_error'

end
