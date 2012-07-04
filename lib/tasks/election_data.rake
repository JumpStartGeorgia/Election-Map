
namespace :election_data do
  desc "create the cache for all events and their default view"
  task :default_event_cache => [:environment] do
    require 'build_cache'

    #build the cache
    BuildCache.default_event_cache
  end

  desc "create cache for all indicators in an event at a shape level"
  task :event_indicator_cache, [:event_id, :shape_type_id] => [:environment] do |t, args|
    require 'build_cache'

    #build the cache
    BuildCache.event_indicator_cache(args.event_id, args.shape_type_id)
  end
end
