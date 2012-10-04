class CoreIndicatorSweeper < ActionController::Caching::Sweeper
  observe CoreIndicator # This sweeper is going to keep an eye on the CoreIndicator model

  # If our sweeper detects that a CoreIndicator was created call this
  def after_create(core_indicator)
    expire_cache_for(core_indicator)
  end

  # If our sweeper detects that a CoreIndicator was updated call this
  def after_update(core_indicator)
    expire_cache_for(core_indicator)
  end

  # If our sweeper detects that a CoreIndicator was deleted call this
  def after_destroy(core_indicator)
    expire_cache_for(core_indicator)
  end

  private
  def expire_cache_for(core_indicator)
Rails.logger.debug "............... clearing all cache because of change to core indicator"
		JsonCache.clear_all
  end
end
