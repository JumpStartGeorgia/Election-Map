class DataSetSweeper < ActionController::Caching::Sweeper
  observe DataSet # This sweeper is going to keep an eye on the DataSet model

  # If our sweeper detects that a DataSet was created call this
  def after_create(date_set)
    expire_cache_for(date_set)
  end

  # If our sweeper detects that a DataSet was updated call this
  def after_update(date_set)
    expire_cache_for(date_set)
  end

  # If our sweeper detects that a DataSet was deleted call this
  def after_destroy(date_set)
    expire_cache_for(date_set)
  end

  private
  def expire_cache_for(date_set)
Rails.logger.debug "............... clearing all cache because of change to core indicator"
		JsonCache.clear_all
  end
end
