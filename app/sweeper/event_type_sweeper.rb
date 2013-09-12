class EventTypeSweeper < ActionController::Caching::Sweeper
  observe EventType # This sweeper is going to keep an eye on the EventType model

  # If our sweeper detects that a EventType was created call this
  def after_create(event_type)
    expire_cache_for(event_type)
  end

  # If our sweeper detects that a EventType was updated call this
  def after_update(event_type)
    expire_cache_for(event_type)
  end

  # If our sweeper detects that a EventType was deleted call this
  def after_destroy(event_type)
    expire_cache_for(event_type)
  end

  private
  def expire_cache_for(event_type)
## - adding/editing event type does not affect cache
#Rails.logger.debug "............... clearing all cache because of change to event types"
#		JsonCache.clear_all
  end
end
