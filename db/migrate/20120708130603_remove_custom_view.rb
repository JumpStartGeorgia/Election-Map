class RemoveCustomView < ActiveRecord::Migration
  def up
    # remove custom view for tbilisi and adjara events
    et = EventTranslation.where("locale = 'en' and (name like '%adjara%' or name like '%tbilisi%')")
    EventCustomView.destroy_all(["event_id in (?)", et.collect(&:event_id)])
    
    # kill the cache
    Rails.cache.clear
  end

  def down
    # do nothing
  end
end
