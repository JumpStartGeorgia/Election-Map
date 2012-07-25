class IndicatorSweeper < ActionController::Caching::Sweeper
  observe Indicator # This sweeper is going to keep an eye on the Indicator model
	require 'json_cache'

  # If our sweeper detects that a Indicator was created call this
  def after_create(indicator)
    expire_cache_for(indicator)
  end

  # If our sweeper detects that a Indicator was updated call this
  def after_update(indicator)
    expire_cache_for(indicator)
  end

  # If our sweeper detects that a Indicator was deleted call this
  def after_destroy(indicator)
    expire_cache_for(indicator)
  end

  private
  def expire_cache_for(indicator)
		JsonCache.clear_all
  end
end
