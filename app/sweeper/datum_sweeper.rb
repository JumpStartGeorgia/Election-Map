class DatumSweeper < ActionController::Caching::Sweeper
  observe Datum # This sweeper is going to keep an eye on the Datum model

  # If our sweeper detects that a Datum was created call this
  def after_create(datum)
    expire_cache_for(datum)
  end

  # If our sweeper detects that a Datum was updated call this
  def after_update(datum)
    expire_cache_for(datum)
  end

  # If our sweeper detects that a Datum was deleted call this
  def after_destroy(datum)
    expire_cache_for(datum)
  end

  private
  def expire_cache_for(datum)
## - don't need since each dataset gets their own unique cache folder
#Rails.logger.debug "............... clearing all cache because of change to data"
#		JsonCache.clear_all
  end
end
