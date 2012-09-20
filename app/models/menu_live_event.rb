class MenuLiveEvent < ActiveRecord::Base
  belongs_to :event
  attr_accessible :event_id, :menu_start_date, :menu_end_date, :data_available_at

  validates :event_id, :menu_start_date, :menu_end_date, :data_available_at, :presence => true

end
