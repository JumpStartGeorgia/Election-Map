class CacheController < ApplicationController
  before_filter :authenticate_user!

  def default_custom_event
		JsonCache.default_event_cache if request.post?
  end

  def custom_event_indicators
		JsonCache.custom_event_indicator_cache if request.post?
  end

  def clear_all
		JsonCache.clear_all if request.post?
  end

  def clear_memory
		JsonCache.clear_cache if request.post?
  end

  def clear_files
		JsonCache.clear_files if request.post?
  end


end
