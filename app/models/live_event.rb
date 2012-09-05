class LiveEvent < ActiveRecord::Base
  belongs_to :event
  attr_accessible :event_id

end
