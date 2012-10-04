class ShapeSweeper < ActionController::Caching::Sweeper
  observe Shape # This sweeper is going to keep an eye on the Shape model

  # If our sweeper detects that a Shape was created call this
  def after_create(shape)
    expire_cache_for(shape)
  end

  # If our sweeper detects that a Shape was updated call this
  def after_update(shape)
    expire_cache_for(shape)
  end

  # If our sweeper detects that a Shape was deleted call this
  def after_destroy(shape)
    expire_cache_for(shape)
  end

  private
  def expire_cache_for(shape)
Rails.logger.debug "............... clearing all cache because of change to shapes"
		JsonCache.clear_all
  end
end
