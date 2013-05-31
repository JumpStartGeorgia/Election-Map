ElectionMap::Application.routes.draw do

	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do

		match '/admin', :to => 'admin#index', :as => :admin, :via => :get
		devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'}

		namespace :admin do
      # cache
	    match '/cache/clear_all' => 'cache#clear_all', :via => [:get, :post]
  		match '/cache/clear_memory' => 'cache#clear_memory', :via => [:get, :post]
	    match '/cache/clear_files', :to => 'cache#clear_files', :via => [:get, :post]
	    match '/cache/custom_event_indicators', :to => 'cache#custom_event_indicators', :via => [:get, :post]
	    match '/cache/default_custom_event', :to => 'cache#default_custom_event', :via => [:get, :post]
	    match '/cache/summary_data', :to => 'cache#summary_data', :via => [:get, :post]

		  # data archives
		  match '/data_archives', :to => 'data_archives#index', :via => :get
		  match '/data_archives/new', :to => 'data_archives#new', :via => [:get, :post]
		  match '/data_archives/:data_archive_folder', :to => 'data_archives#show', :via => :get

      # core indicator text
		  match '/core_indicator_text', :to => 'core_indicator_text#index', :via => :get
		  match '/core_indicator_text/:id/edit', :to => 'core_indicator_text#edit', :as => 'edit_core_indicator_text', :via => [:get,:post]

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
      resources :data_sets do
			  collection do
	        get :load_data
	        post :load_data
			  end
			  member do
				  get :create_cache
			  end
		  end
  	  resources :event_custom_views
  	  resources :event_indicator_relationships
  	  resources :event_types
  	  resources :events
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
      resources :menu_live_events
      resources :news
  	  resources :pages

  	  resources :shape_types
	    resources :shapes do
			  collection do
	        get :upload
	        post :upload
	        get :export
	        get :delete
	        post :delete
			  end
		  end
			resources :users
		end


    # root
		match '/export', :to => 'root#export', :as => :export, :via => :post, :defaults => {:format => 'svg'}
		match '/routing_error', :to => 'root#routing_error'
		match '/download/csv/event/:event_id/shape_type/:shape_type_id/shape/:shape_id(/event_name/:event_name(/map_title/:map_title(/indicator/:indicator_id)))', :to => 'root#download', :as => :download_data_csv, :via => :get, :defaults => {:format => 'csv'}
		match '/download/xls/event/:event_id/shape_type/:shape_type_id/shape/:shape_id(/event_name/:event_name(/map_title/:map_title(/indicator/:indicator_id)))', :to => 'root#download', :as => :download_data_xls, :via => :get, :defaults => {:format => 'xls'}
		match '/archive', :to => 'root#archive', :as => :archive, :via => :get
		match '/contact' => 'messages#new', :as => 'contact', :via => :get
		match '/contact' => 'messages#create', :as => 'contact', :via => :post
		match '/contact_success' => 'messages#success', :as => 'contact_success', :via => :get
		match '/shape_types/event/:event_id', :to => 'shape_types#by_event', :as => :shape_types_by_event, :via => :get, :defaults => {:format => 'json'}
		match '/indicators/event/:event_id/shape_type/:shape_type_id', :to => 'indicators#by_event_shape_type', :as => :indicators_by_event_shape_type, :via => :get, :defaults => {:format => 'json'}
		match '/event_indicator_relationships/render_js_blocks/:id/:type/:counter', :to => 'event_indicator_relationships#render_js_blocks', :via => :get, :defaults => {:format => 'json'}

    # routes to root#index
		match '/event_type/:event_type_id' => 'root#index', :as => 'event_type_map', :via => :get
		match '/event_type/:event_type_id/event/:event_id(/shape/:shape_id(/shape_type/:shape_type_id(/indicator/:indicator_id(/custom_view/:custom_view(/highlight_shape/:highlight_shape)))))' => 'root#index', :as => 'indicator_map', :via => :get
		match '/event_type/:event_type_id/event/:event_id/indicator/:indicator_id/change_shape/:change_shape_type/parent_clickable/:parent_shape_clickable(/shape/:shape_id(/shape_type/:shape_type_id(/custom_view/:custom_view)))' => 'root#index', :as => 'shape_level_map', :via => :get
		match '/event_type/:event_type_id/event/:event_id/shape_type/:shape_type_id/shape/:shape_id/indicator_type/:indicator_type_id/view_type/:view_type(/custom_view/:custom_view(/highlight_shape/:highlight_shape))' => 'root#index', :as => 'summary_map', :via => :get
		match '/event_type/:event_type_id/event/:event_id/indicator_type/:indicator_type_id/view_type/:view_type/change_shape/:change_shape_type/parent_clickable/:parent_shape_clickable(/shape/:shape_id(/shape_type/:shape_type_id(/custom_view/:custom_view)))' => 'root#index', :as => 'summary_shape_level_map', :via => :get

    # other
    match '/data_archives', :to => 'other#data_archives', :as => :data_archives, :via => :get
    match '/data_archives/:data_archive_folder', :to => 'other#data_archive', :as => :data_archive, :via => :get
    match '/news', :to => 'other#news', :as => :news, :via => :get
    match '/about', :to => 'other#about', :as => :about, :via => :get
    match '/data_source', :to => 'other#data_source', :as => :data_source, :via => :get
    match '/export_help', :to => 'other#export_help', :as => :export_help, :via => :get
    match '/indicators', :to => 'other#indicators', :as => :indicator_profiles, :via => :get
    match '/indicators/:id', :to => 'other#indicator', :as => :indicator_profile, :via => :get
    match '/districts', :to => 'other#districts', :as => :district_profiles, :via => :get
    match '/districts/:id', :to => 'other#district', :as => :district_profile, :via => :get

    # json routes
		# core indicator events
		match '/json/core_indicator_events', :to => 'json#core_indicator_events', :as => :json_core_indicator_events, :via => :get, :defaults => {:format => 'json'}
		match '/json/core_indicator_events_table', :to => 'json#core_indicator_events_table', :as => :json_core_indicator_events_table, :via => :get, :defaults => {:format => 'json'}
		# district events
		match '/json/district_events', :to => 'json#district_events', :as => :json_district_events, :via => :get, :defaults => {:format => 'json'}
		match '/json/district_events_table', :to => 'json#district_events_table', :as => :json_district_events_table, :via => :get, :defaults => {:format => 'json'}
		# menu
		match '/json/event_menu', :to => 'json#event_menu', :as => :json_event_menu, :via => :get, :defaults => {:format => 'json'}
		match '/json/live_event_menu', :to => 'json#live_event_menu', :as => :json_live_event_menu, :via => :get, :defaults => {:format => 'json'}
		# current data set id
		match '/json/current_data_set/event/:event_id/data_type/:data_type', :to => 'json#current_data_set', :as => :json_current_data_set, :via => :get, :defaults => {:format => 'json'}
		# shape
		match '/json/shape/:id/shape_type/:shape_type_id', :to => 'json#shape', :as => :json_shape, :via => :get, :defaults => {:format => 'json'}
		match '/json/children_shapes/:parent_id/shape_type/:shape_type_id/event/:event_id(/parent_clickable/:parent_shape_clickable)', :to => 'json#children_shapes', :as => :json_children_shapes, :via => :get, :defaults => {:format => 'json'}
		match '/json/custom_children_shapes/:parent_id/shape_type/:shape_type_id', :to => 'json#custom_children_shapes', :as => :json_custom_children_shapes, :via => :get, :defaults => {:format => 'json'}
		# data
		match '/json/children_data/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator/:indicator_id(/parent_clickable/:parent_shape_clickable)', :to => 'json#children_data', :as => :json_children_data, :via => :get, :defaults => {:format => 'json'}
		match '/json/custom_children_data/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator/:indicator_id', :to => 'json#custom_children_data', :as => :json_custom_children_data, :via => :get, :defaults => {:format => 'json'}
		match '/json/summary_children_data/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator_type/:indicator_type_id(/parent_clickable/:parent_shape_clickable)', :to => 'json#summary_children_data', :as => :json_summary_children_data, :via => :get, :defaults => {:format => 'json'}
		match '/json/summary_custom_children_data/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator_type/:indicator_type_id', :to => 'json#summary_custom_children_data', :as => :json_summary_custom_children_data, :via => :get, :defaults => {:format => 'json'}
    # core indicator event type data
		match '/json/indicator_event_type_summary_data/:core_indicator_id/event_type/:event_type_id(/shape_type/:shape_type_id/common_id/:common_id/common_name/:common_name)', :to => 'json#indicator_event_type_summary_data', :as => :json_indicator_event_type_summary_data, :via => :get, :defaults => {:format => 'json'}
		match '/json/indicator_event_type_data/:core_indicator_id/event_type/:event_type_id(/shape_type/:shape_type_id/common_id/:common_id/common_name/:common_name)', :to => 'json#indicator_event_type_data', :as => :json_indicator_event_type_data, :via => :get, :defaults => {:format => 'json'}
    # shape event type data
		match '/json/district_event_type_summary_data/:common_id/event_type/:event_type_id', :to => 'json#district_event_type_summary_data', :as => :json_district_event_type_summary_data, :via => :get, :defaults => {:format => 'json'}
#		match '/json/district_event_type_data/:core_indicator_id/event_type/:event_type_id(/shape_type/:shape_type_id/common_id/:common_id/common_name/:common_name)', :to => 'json#indicator_event_type_data', :as => :json_indicator_event_type_data, :via => :get, :defaults => {:format => 'json'}


=begin old routes
    # json routes
		match '/json/shape/:id/shape_type/:shape_type_id', :to => 'json#shape', :as => :json_shape, :via => :get, :defaults => {:format => 'json'}
		match '/json/children_shapes/:parent_id/shape_type/:shape_type_id/event/:event_id(/parent_clickable/:parent_shape_clickable(/indicator/:indicator_id(/custom_view/:custom_view)))', :to => 'json#children_shapes', :as => :json_children_shapes, :via => :get, :defaults => {:format => 'json'}
		match '/json/custom_children_shapes/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator/:indicator_id(/custom_view/:custom_view)', :to => 'json#custom_children_shapes', :as => :json_custom_children_shapes, :via => :get, :defaults => {:format => 'json'}
		match '/json/summary_children_shapes/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator_type/:indicator_type_id(/parent_clickable/:parent_shape_clickable(/custom_view/:custom_view))', :to => 'json#summary_children_shapes', :as => :json_summary_children_shapes, :via => :get, :defaults => {:format => 'json'}
		match '/json/summary_custom_children_shapes/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator_type/:indicator_type_id(/custom_view/:custom_view)', :to => 'json#summary_custom_children_shapes', :as => :json_summary_custom_children_shapes, :via => :get, :defaults => {:format => 'json'}
		match '/json/summary_custom_children_shapes2/:parent_id/shape_type/:shape_type_id/event/:event_id/indicator_type/:indicator_type_id(/custom_view/:custom_view)', :to => 'json#summary_custom_children_shapes2', :as => :json_summary_custom_children_shapes2, :via => :get, :defaults => {:format => 'json'}
		match '/json/event_menu', :to => 'json#event_menu', :as => :json_event_menu, :via => :get, :defaults => {:format => 'json'}
		match '/json/live_event_menu', :to => 'json#live_event_menu', :as => :json_live_event_menu, :via => :get, :defaults => {:format => 'json'}
		match '/json/current_data_set/event/:event_id/data_type/:data_type', :to => 'json#current_data_set', :as => :json_current_data_set, :via => :get, :defaults => {:format => 'json'}


		# cache
		match '/admin/cache/clear_all', :to => 'cache#clear_all', :as => :cache_clear_all, :via => [:get, :post]
		match '/admin/cache/clear_memory', :to => 'admin::cache#clear_memory', :as => :cache_clear_memory, :via => [:get, :post]
		match '/admin/cache/clear_files', :to => 'cache#clear_files', :as => :cache_clear_files, :via => [:get, :post]
		match '/admin/cache/custom_event_indicators', :to => 'cache#custom_event_indicators',
			:as => :cache_custom_event_indicators, :via => [:get, :post]
		match '/admin/cache/default_custom_event', :to => 'cache#default_custom_event',
			:as => :cache_default_custom_event, :via => [:get, :post]
		match '/admin/cache/summary_data', :to => 'cache#summary_data',
			:as => :cache_summary_data, :via => [:get, :post]
=end

		match '/data_table/event_type/:event_type_id/event/:event_id/shape/:shape_id/shape_type/:shape_type_id/child_shape_type/:child_shape_type_id/indicator/:indicator_id/view_type/:view_type/summary_view_type/:summary_view_type_name(/custom_view/:custom_view)', :to => 'root#data_table', :as => :data_table, :via => :get

		root :to => 'root#index'

	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

	# Catch unroutable paths and send to the routing error handler
#	match '*a', :to => 'root#routing_error'

end
