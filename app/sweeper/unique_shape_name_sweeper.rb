class UniqueShapeNameSweeper < ActionController::Caching::Sweeper
  observe UniqueShapeName # This sweeper is going to keep an eye on the UniqueShapeName model

  # If our sweeper detects that a UniqueShapeName was created call this
  def after_create(unique_shape_name)
    expire_cache_for(unique_shape_name)
  end

  # If our sweeper detects that a UniqueShapeName was updated call this
  def after_update(unique_shape_name)
    expire_cache_for(unique_shape_name)
  end

  # If our sweeper detects that a UniqueShapeName was deleted call this
  def after_destroy(unique_shape_name)
    expire_cache_for(unique_shape_name)
  end

  private
  def expire_cache_for(unique_shape_name)
Rails.logger.debug "............... clearing all cache because of change to unique shape name"
		JsonCache.clear_all
  end
end
