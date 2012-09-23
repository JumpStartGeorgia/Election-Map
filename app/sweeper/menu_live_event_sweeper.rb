class MenuLiveEventSweeper < ActionController::Caching::Sweeper
  observe MenuLiveEvent # This sweeper is going to keep an eye on the MenuLiveEvent model

  # If our sweeper detects that a MenuLiveEvent was created call this
  def after_create(menu_live_event)
    expire_cache_for(menu_live_event)
  end

  # If our sweeper detects that a MenuLiveEvent was updated call this
  def after_update(menu_live_event)
    expire_cache_for(menu_live_event)
  end

  # If our sweeper detects that a MenuLiveEvent was deleted call this
  def after_destroy(menu_live_event)
    expire_cache_for(menu_live_event)
  end

  private
  def expire_cache_for(menu_live_event)
    # expire the live event menu cache
    I18n.available_locales.each do |locale|
      Rails.cache.delete("live_event_menu_json_#{locale}")
    end
  end
end
