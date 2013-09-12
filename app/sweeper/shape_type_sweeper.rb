class ShapeTypeSweeper < ActionController::Caching::Sweeper
  observe ShapeType # This sweeper is going to keep an eye on the ShapeType model

  # If our sweeper detects that a ShapeType was created call this
  def after_create(shape_type)
    expire_cache_for(shape_type)
  end

  # If our sweeper detects that a ShapeType was updated call this
  def after_update(shape_type)
    expire_cache_for(shape_type)
  end

  # If our sweeper detects that a ShapeType was deleted call this
  def after_destroy(shape_type)
    expire_cache_for(shape_type)
  end

  private
  def expire_cache_for(shape_type)
Rails.logger.debug "............... clearing all shape file cache using this shape type"

		JsonCache.clear_shape_files_by_type(shape_type.id)
  end
end
