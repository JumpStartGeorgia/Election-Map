class IndicatorTypeSweeper < ActionController::Caching::Sweeper
  observe IndicatorType # This sweeper is going to keep an eye on the IndicatorType model
 
  # If our sweeper detects that a IndicatorType was created call this
  def after_create(indicator_type)
    expire_cache_for(indicator_type)
  end
 
  # If our sweeper detects that a IndicatorType was updated call this
  def after_update(indicator_type)
    expire_cache_for(indicator_type)
  end
 
  # If our sweeper detects that a IndicatorType was deleted call this
  def after_destroy(indicator_type)
    expire_cache_for(indicator_type)
  end
 
  private
  def expire_cache_for(indicator_type)
		Rails.cache.clear
  end
end
