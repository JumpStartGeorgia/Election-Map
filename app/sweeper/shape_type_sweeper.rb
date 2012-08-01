class ShapeTypeSweeper < ActionController::Caching::Sweeper
  observe ShapeType # This sweeper is going to keep an eye on the ShapeType model
	require 'json_cache'

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
		JsonCache.clear_all
  end
end
