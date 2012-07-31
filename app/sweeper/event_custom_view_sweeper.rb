class EventCustomViewSweeper < ActionController::Caching::Sweeper
  observe EventCustomView # This sweeper is going to keep an eye on the EventCustomView model
	require 'json_cache'

  # If our sweeper detects that a EventCustomView was created call this
  def after_create(event)
    expire_cache_for(event)
  end

  # If our sweeper detects that a EventCustomView was updated call this
  def after_update(event)
    expire_cache_for(event)
  end

  # If our sweeper detects that a EventCustomView was deleted call this
  def after_destroy(event)
    expire_cache_for(event)
  end

  private
  def expire_cache_for(event)
		JsonCache.clear_all
  end
end
