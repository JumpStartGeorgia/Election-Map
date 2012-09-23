class MenuLiveEvent < ActiveRecord::Base
  belongs_to :event
  attr_accessible :event_id, :menu_start_date, :menu_end_date, :data_available_at

  validates :event_id, :menu_start_date, :menu_end_date, :data_available_at, :presence => true

  before_save :fix_timezone
  
  def fix_timezone
#    self.data_available_at = self.data_available_at.in_time_zone('Tbilisi')
  end
  
end
