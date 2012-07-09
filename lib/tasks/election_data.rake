
namespace :election_data do
	##############################
  desc "calls default_event_cache and custom_event_indicator_cache"
  task :build_default_and_custom_cache => [:environment] do
    require 'build_cache'

    BuildCache.build_default_and_custom_cache
    BuildCache.custom_event_indicator_cache
  end

	##############################
  desc "create the cache for all events and their default view"
  task :default_event_cache => [:environment] do
    require 'build_cache'

    #build the cache
    BuildCache.default_event_cache
  end

	##############################
  desc "create cache for all indicators for all events that have a custom view"
  task :custom_event_indicator_cache => [:environment] do
    require 'build_cache'

    #build the cache
    BuildCache.custom_event_indicator_cache
  end

end
