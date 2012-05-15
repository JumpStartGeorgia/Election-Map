class LocaleSweeper < ActionController::Caching::Sweeper
  observe Locale # This sweeper is going to keep an eye on the Locale model
 
  # If our sweeper detects that a Locale was created call this
  def after_create(locale)
    expire_cache_for(locale)
  end
 
  # If our sweeper detects that a Locale was updated call this
  def after_update(locale)
    expire_cache_for(locale)
  end
 
  # If our sweeper detects that a Locale was deleted call this
  def after_destroy(locale)
    expire_cache_for(locale)
  end
 
  private
  def expire_cache_for(locale)
#		Rails.cache.delete("locales")
		Rails.cache.clear
  end
end
