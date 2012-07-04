DEFAULT_EVENT_CACHE_QUEUE = GirlFriday::WorkQueue.new(:default_event_cache, :size => 3) do |msg|
  require 'build_cache'
#	BuildCache.default_event_cache
	Event.find(msg[:id])
end

EVENT_INDICATOR_CACHE_QUEUE = GirlFriday::WorkQueue.new(:event_indicator_cache, :size => 3) do |msg|
  require 'build_cache'
	BuildCache.event_indicator_cache(msg[:event_id], msg[:shape_type_id])
end
