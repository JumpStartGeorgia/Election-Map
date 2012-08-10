class CacheController < ApplicationController
  before_filter :authenticate_user!

  def default_custom_event
		if request.post?
			JsonCache.default_event_cache
			flash[:notice] = I18n.t('cache.default_custom_event.created')
		end
  end

  def custom_event_indicators
		if request.post?
			JsonCache.custom_event_indicator_cache
			flash[:notice] = I18n.t('cache.custom_event_indicators.created')
		end
  end

  def clear_all
		if request.post?
			JsonCache.clear_all
			flash[:notice] = I18n.t('cache.clear_all.cleared')
		end
  end

  def clear_memory
		if request.post?
			JsonCache.clear_cache
			flash[:notice] = I18n.t('cache.clear_memory.cleared')
		end
  end

  def clear_files
		if request.post?
			JsonCache.clear_files
			flash[:notice] = I18n.t('cache.clear_files.cleared')
		end
  end


end
