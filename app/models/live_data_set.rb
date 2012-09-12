class LiveDataSet < ActiveRecord::Base
  belongs_to :event
  attr_accessible :event_id, :precincts_completed, :precincts_total, :timestamp, :show_to_public

  validates :event_id, :precincts_completed, :precincts_total, :timestamp, :presence => true
  
end
