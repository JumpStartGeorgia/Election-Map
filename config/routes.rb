ElectionMap::Application.routes.draw do
	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		devise_for :users


	  resources :core_indicators do
	    collection do
	      get :colors
      end
    end
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
	  resources :event_custom_views
	  resources :event_indicator_relationships
	  resources :event_types
    resources :news
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
		match '/download/csv/event/:event_id/shape_type/:shape_type_id/shape/:shape_id(/event_name/:event_name(/map_title/:map_title(/indicator/:indicator_id)))', :to => 'root#download', :as => :download_data_csv, :via => :get, :defaults => {:format => 'csv'}
		match '/download/xls/event/:event_id/shape_type/:shape_type_id/shape/:shape_id(/event_name/:event_name(/map_title/:map_title(/indicator/:indicator_id)))', :to => 'root#download', :as => :download_data_xls, :via => :get, :defaults => {:format => 'xls'}
		match '/archive', :to => 'root#archive', :as => :archive, :via => :get
		match '/contact' => 'messages#new', :as => 'contact', :via => :get
		match '/contact' => 'messages#create', :as => 'contact', :via => :post
		match '/contact_success' => 'messages#success', :as => 'contact_success', :via => :get
		match '/pages/view/:name(/:layout)', :to => 'pages#view', :as => :view_pages, :via => :get
		match '/shape_types/event/:event_id', :to => 'shape_types#by_event', :as => :shape_types_by_event, :via => :get, :defaults => {:format => 'json'}
		match '/indicators/event/:event_id/shape_type/:shape_type_id', :to => 'indicators#by_event_shape_type', :as => :indicators_by_event_shape_type, :via => :get, :defaults => {:format => 'json'}
		match '/event_indicator_relationships/render_js_blocks/:id/:type/:counter', :to => 'event_indicator_relationships#render_js_blocks', :via => :get, :defaults => {:format => 'json'}

		# cache
		match '/cache/clear_all', :to => 'cache#clear_all', :as => :cache_clear_all, :via => :get
		match '/cache/clear_all', :to => 'cache#clear_all', :as => :cache_clear_all, :via => :post
		match '/cache/clear_memory', :to => 'cache#clear_memory', :as => :cache_clear_memory, :via => :get
		match '/cache/clear_memory', :to => 'cache#clear_memory', :as => :cache_clear_memory, :via => :post
		match '/cache/clear_files', :to => 'cache#clear_files', :as => :cache_clear_files, :via => :get
		match '/cache/clear_files', :to => 'cache#clear_files', :as => :cache_clear_files, :via => :post
		match '/cache/custom_event_indicators', :to => 'cache#custom_event_indicators',
			:as => :cache_custom_event_indicators, :via => :get
		match '/cache/custom_event_indicators', :to => 'cache#custom_event_indicators',
			:as => :cache_custom_event_indicators, :via => :post
		match '/cache/default_custom_event', :to => 'cache#default_custom_event',
			:as => :cache_default_custom_event, :via => :get
		match '/cache/default_custom_event', :to => 'cache#default_custom_event',
			:as => :cache_default_custom_event, :via => :post
		match '/cache/summary_data', :to => 'cache#summary_data',
			:as => :cache_summary_data, :via => :get
		match '/cache/summary_data', :to => 'cache#summary_data',
			:as => :cache_summary_data, :via => :post

		# data archives
		match '/data_archives/new', :to => 'data_archives#new', :as => :data_archives_new, :via => :get
		match '/data_archives/new', :to => 'data_archives#new', :as => :data_archives_new, :via => :post
		match '/data_archives', :to => 'data_archives#index', :as => :data_archives, :via => :get
		match '/data_archives/:data_archive_folder', :to => 'data_archives#show', :as => :data_archive, :via => :get


    # routes to root#index
		match '/event_type/:event_type_id' => 'root#index', :as => 'event_type_map', :via => :get
		match '/event_type/:event_type_id/event/:event_id(/shape/:shape_id(/shape_type/:shape_type_id(/indicator/:indicator_id(/custom_view/:custom_view(/highlight_shape/:highlight_shape)))))' => 'root#index', :as => 'indicator_map', :via => :get
		match '/event_type/:event_type_id/event/:event_id/indicator/:indicator_id/change_shape/:change_shape_type/parent_clickable/:parent_shape_clickable(/shape/:shape_id(/shape_type/:shape_type_id(/custom_view/:custom_view)))' => 'root#index', :as => 'shape_level_map', :via => :get
		match '/event_type/:event_type_id/event/:event_id/shape_type/:shape_type_id/shape/:shape_id/indicator_type/:indicator_type_id/view_type/:view_type(/custom_view/:custom_view(/highlight_shape/:highlight_shape))' => 'root#index', :as => 'summary_map', :via => :get
		match '/event_type/:event_type_id/event/:event_id/indicator_type/:indicator_type_id/view_type/:view_type/change_shape/:change_shape_type/parent_clickable/:parent_shape_clickable(/shape/:shape_id(/shape_type/:shape_type_id(/custom_view/:custom_view)))' => 'root#index', :as => 'summary_shape_level_map', :via => :get

    # json routes
		# menu
		match '/json/event_menu', :to => 'json#event_menu', :as => :json_event_menu, :via => :get, :defaults => {:format => 'json'}
		# shape
		match '/json/shape/:id/shape_type/:shape_type_id', :to => 'json#shape', :as => :json_shape, :via => :get, :defaults => {:format => 'json'}
		match '/json/children_shapes/:parent_id/shape_type/:shape_type_id/event/:event_id(/parent_clickable/:parent_shape_clickable)', :to => 'json#children_shapes', :as => :json_children_shapes, :via => :get, :defaults => {:format => 'json'}
		match '/json/custom_children_shapes/:parent_id/shape_type/:shape_type_id', :to => 'json#custom_children_shapes', :as => :json_custom_children_shapes, :via => :get, :defaults => {:format => 'json'}
		# data
		match '/json/children_data/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator/:indicator_id(/parent_clickable/:parent_shape_clickable)', :to => 'json#children_data', :as => :json_children_data, :via => :get, :defaults => {:format => 'json'}
		match '/json/custom_children_data/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator/:indicator_id', :to => 'json#custom_children_data', :as => :json_custom_children_data, :via => :get, :defaults => {:format => 'json'}
		match '/json/summary_children_data/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator_type/:indicator_type_id(/parent_clickable/:parent_shape_clickable)', :to => 'json#summary_children_data', :as => :json_summary_children_data, :via => :get, :defaults => {:format => 'json'}
		match '/json/summary_custom_children_data/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator_type/:indicator_type_id', :to => 'json#summary_custom_children_data', :as => :json_summary_custom_children_data, :via => :get, :defaults => {:format => 'json'}



		match '/data_table/event_type/:event_type_id/event/:event_id/shape/:shape_id/shape_type/:shape_type_id/child_shape_type/:child_shape_type_id/indicator/:indicator_id/view_type/:view_type/summary_view_type/:summary_view_type_name(/custom_view/:custom_view)', :to => 'root#data_table', :as => :data_table, :via => :get

		root :to => 'root#index'

	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

	# Catch unroutable paths and send to the routing error handler
#	match '*a', :to => 'root#routing_error'

end
