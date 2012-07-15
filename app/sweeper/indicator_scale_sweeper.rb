class IndicatorScaleSweeper < ActionController::Caching::Sweeper
  observe IndicatorScale # This sweeper is going to keep an eye on the IndicatorScale model
	require 'json_cache'

  # If our sweeper detects that a IndicatorScale was created call this
  def after_create(indicator_scale)
    expire_cache_for(indicator_scale)
  end

  # If our sweeper detects that a IndicatorScale was updated call this
  def after_update(indicator_scale)
    expire_cache_for(indicator_scale)
  end

  # If our sweeper detects that a IndicatorScale was deleted call this
  def after_destroy(indicator_scale)
    expire_cache_for(indicator_scale)
  end

  private
  def expire_cache_for(indicator_scale)
		JsonCache.clear
  end
end
