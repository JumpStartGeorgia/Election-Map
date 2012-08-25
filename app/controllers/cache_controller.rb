class CacheController < ApplicationController
  before_filter :authenticate_user!

  def summary_data
		if request.post?
			start = Time.now
			JsonCache.summary_data_cache
			flash[:notice] = I18n.t('cache.summary_data_cache.created')
			send_status_update(I18n.t('cache.summary_data.created'), Time.now-start)
		end
  end

  def default_custom_event
		if request.post?
			start = Time.now
			JsonCache.default_event_cache
			flash[:notice] = I18n.t('cache.default_custom_event.created')
			send_status_update(I18n.t('cache.default_custom_event.created'), Time.now-start)
		end
  end

  def custom_event_indicators
		if request.post?
			start = Time.now
			JsonCache.custom_event_indicator_cache
			flash[:notice] = I18n.t('cache.custom_event_indicators.created')
			send_status_update(I18n.t('cache.custom_event_indicators.created'), Time.now-start)
		end
  end

  def clear_all
		if request.post?
			start = Time.now
			JsonCache.clear_all
			flash[:notice] = I18n.t('cache.clear_all.cleared')
			send_status_update(I18n.t('cache.clear_all.cleared'), Time.now-start)
		end
  end

  def clear_memory
		if request.post?
			start = Time.now
			JsonCache.clear_cache
			flash[:notice] = I18n.t('cache.clear_memory.cleared')
			send_status_update(I18n.t('cache.clear_memory.cleared'), Time.now-start)
		end
  end

  def clear_files
		if request.post?
			start = Time.now
			JsonCache.clear_files
			flash[:notice] = I18n.t('cache.clear_files.cleared')
			send_status_update(I18n.t('cache.clear_files.cleared'), Time.now-start)
		end
  end


end
