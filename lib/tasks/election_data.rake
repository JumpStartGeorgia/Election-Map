require 'json_cache'
require 'data_archive'

namespace :election_data do
	##############################
  desc "calls default_event_cache and custom_event_indicator_cache"
  task :build_default_and_custom_cache => [:environment] do

    JsonCache.build_default_and_custom_cache
    JsonCache.custom_event_indicator_cache
  end

	##############################
  desc "create the cache for all events and their default view"
  task :default_event_cache => [:environment] do

    #build the cache
    JsonCache.default_event_cache
  end

	##############################
  desc "create cache for all indicators for all events that have a custom view"
  task :custom_event_indicator_cache => [:environment] do

    #build the cache
    JsonCache.custom_event_indicator_cache
  end

	##############################
  desc "create cache for the summary data used to generate the bar charts in the map popup"
  task :summary_data_cache => [:environment] do

    #build the cache
    JsonCache.summary_data_cache
  end

	##############################
  desc "create archive of all event data in database"
  task :data_archive_files => [:environment] do

    #create the data archive files
    DataArchive.create_files
  end

end
