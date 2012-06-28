ElectionMap::Application.routes.draw do



	#--------------------------------	
	# all resources should be within the scope block below
	#--------------------------------	
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		devise_for :users


	  resources :core_indicators
	  resources :data do
			collection do
	      get :upload
	      post :upload
	      get :export
	      get :delete
	      post :delete
			end
		end
	  resources :indicator_scales do
			collection do
	      get :upload
	      post :upload
	      get :export
			end
	  end
    resources :indicator_types
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
	  resources :events
	  resources :event_types
	  resources :pages
	  resources :shapes do
			collection do
	      get :upload
	      post :upload
	      get :export
	      get :delete
	      post :delete
			end
		end
	  resources :shape_types


		match '/export', :to => 'root#export', :as => :export, :via => :post, :defaults => {:format => 'svg'}
		match '/routing_error', :to => 'root#routing_error'
		match '/admin', :to => 'root#admin', :as => :admin, :via => :get
		match '/clear_cache', :to => 'root#clear_cache', :as => :clear_cache, :via => :get
		match '/download/event/:event_id/shape_type/:shape_type_id/shape/:shape_id(/event_name/:event_name(/map_title/:map_title(/indicator/:indicator_id)))', :to => 'root#download', :as => :download_data, :via => :get
		match '/contact' => 'messages#new', :as => 'contact', :via => :get
		match '/contact' => 'messages#create', :as => 'contact', :via => :post
		match '/contact_success' => 'messages#success', :as => 'contact_success', :via => :get
		match '/pages/view/:name(/:layout)', :to => 'pages#view', :as => :view_pages, :via => :get
		match '/shape_types/event/:event_id', :to => 'shape_types#by_event', :as => :shape_types_by_event, :via => :get, :defaults => {:format => 'json'}
		match '/indicators/event/:event_id/shape_type/:shape_type_id', :to => 'indicators#by_event_shape_type', :as => :indicators_by_event_shape_type, :via => :get, :defaults => {:format => 'json'}

    # routes to root#index
		match '/event_type/:event_type_id' => 'root#index', :as => 'event_type_map', :via => :get
		match '/event_type/:event_type_id/event/:event_id(/shape/:shape_id(/shape_type/:shape_type_id(/indicator/:indicator_id(/custom_view/:custom_view))))' => 'root#index', :as => 'indicator_map', :via => :get
		match '/event_type/:event_type_id/event/:event_id/indicator/:indicator_id/change_shape/:change_shape_type/parent_clickable/:parent_shape_clickable(/shape/:shape_id(/shape_type/:shape_type_id(/custom_view/:custom_view)))' => 'root#index', :as => 'shape_level_map', :via => :get
		match '/event_type/:event_type_id/event/:event_id/shape_type/:shape_type_id/shape/:shape_id/indicator_type/:indicator_type_id/view_type/:view_type(/custom_view/:custom_view)' => 'root#index', :as => 'summary_map', :via => :get
		match '/event_type/:event_type_id/event/:event_id/indicator_type/:indicator_type_id/view_type/:view_type/change_shape/:change_shape_type/parent_clickable/:parent_shape_clickable(/shape/:shape_id(/shape_type/:shape_type_id(/custom_view/:custom_view)))' => 'root#index', :as => 'summary_shape_level_map', :via => :get

    # json routes
		match '/json/shape/:id', :to => 'json#shape', :as => :json_shape, :via => :get, :defaults => {:format => 'json'}
		match '/json/children_shapes/:parent_id(/parent_clickable/:parent_shape_clickable(/indicator/:indicator_id))', :to => 'json#children_shapes', :as => :json_children_shapes, :via => :get, :defaults => {:format => 'json'}
		match '/json/grandchildren_shapes/:parent_id/indicator/:indicator_id', :to => 'json#grandchildren_shapes', :as => :json_grandchildren_shapes, :via => :get, :defaults => {:format => 'json'}
		match '/json/summary_children_shapes/:parent_id/event/:event_id/indicator_type/:indicator_type_id(/parent_clickable/:parent_shape_clickable)', :to => 'json#summary_children_shapes', :as => :json_summary_children_shapes, :via => :get, :defaults => {:format => 'json'}
		match '/json/summary_grandchildren_shapes/:parent_id/event/:event_id/indicator_type/:indicator_type_id', :to => 'json#summary_grandchildren_shapes', :as => :json_summary_grandchildren_shapes, :via => :get, :defaults => {:format => 'json'}
		match '/json/summary_data/shape/:shape_id/event/:event_id/indicator_type/:indicator_type_id(/limit/:limit)', :to => 'json#summary_data', :as => :json_summary_data, :via => :get, :defaults => {:format => 'json'}


		root :to => 'root#index'

	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

	# Catch unroutable paths and send to the routing error handler
#	match '*a', :to => 'root#routing_error'

end
