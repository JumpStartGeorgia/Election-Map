class EventIndicatorRelationshipSweeper < ActionController::Caching::Sweeper
  observe EventIndicatorRelationship # This sweeper is going to keep an eye on the EventIndicatorRelationship model

  # If our sweeper detects that a EventIndicatorRelationship was created call this
  def after_create(event)
    expire_cache_for(event)
  end

  # If our sweeper detects that a EventIndicatorRelationship was updated call this
  def after_update(event)
    expire_cache_for(event)
  end

  # If our sweeper detects that a EventIndicatorRelationship was deleted call this
  def after_destroy(event)
    expire_cache_for(event)
  end

  private
  def expire_cache_for(event)
Rails.logger.debug "............... clearing all cache because of change to event indicator relationships"
		JsonCache.clear_all
  end
end
