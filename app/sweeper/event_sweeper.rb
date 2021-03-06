class EventSweeper < ActionController::Caching::Sweeper
  observe Event # This sweeper is going to keep an eye on the Event model

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
Rails.logger.debug "............... clearing cache for event #{event.id} because of changes"
		JsonCache.clear_all_data(event.id)
  end
end
