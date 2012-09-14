class MenuLiveEvent < ActiveRecord::Base
  belongs_to :event
  attr_accessible :event_id, :menu_start_date, :menu_end_date

  validates :event_id, :menu_start_date, :menu_end_date, :presence => true

end
