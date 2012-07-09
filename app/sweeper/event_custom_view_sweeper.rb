class EventCustomViewSweeper < ActionController::Caching::Sweeper
  observe EventCustomView # This sweeper is going to keep an eye on the Event model
 
  # If our sweeper detects that a Event was created call this
  def after_create(event)
    expire_cache_for(event)
  end
 
  # If our sweeper detects that a Event was updated call this
  def after_update(event)
    expire_cache_for(event)
  end
 
  # If our sweeper detects that a Event was deleted call this
  def after_destroy(event)
    expire_cache_for(event)
  end
 
  private
  def expire_cache_for(event)
		# delete the cache for the event_type this event belongs/belonged to
#		Rails.cache.delete("events_by_type_#{event.event_type_id}")
		Rails.cache.clear
  end
end
