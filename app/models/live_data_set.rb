class LiveDataSet < ActiveRecord::Base
  belongs_to :event
  has_many :live_data, :dependent => :destroy
  
  attr_accessible :event_id, :precincts_completed, :precincts_total, :timestamp, :show_to_public

  validates :event_id, :precincts_completed, :precincts_total, :timestamp, :presence => true
  
  after_save :update_live_data_flag
  before_destroy :destroy_live_data_flag
  
  def precincts_percentage
    ActionController::Base.helpers.number_to_percentage(self.precincts_completed.to_f/self.precincts_total*100) if self.precincts_completed && self.precincts_total
  end
  
  # - if show to pulic is true, turn on the has_live_data for this event
  # - if show public is false, and no other datasets for this event are true, turn off flag
  def update_live_data_flag
    if self.show_to_public
      self.event.has_live_data = true
      self.event.save
    else
      datasets = LiveDataSet.where(:event_id => self.event_id)
      if datasets && !datasets.empty?
        has_live_data = datasets.select{|x| x.show_to_public}
        if !has_live_data || has_live_data.empty?
          self.event.has_live_data = false
          self.event.save
        end
      end
    end
    # clear the menu cache
    I18n.available_locales.each do |locale|
      Rails.cache.delete("live_event_menu_json_#{locale}")
      Rails.cache.delete("event_menu_json_#{locale}")
      Rails.cache.delete("events_by_type_#{self.event.event_type_id}_#{locale}")
    end
  end
  
  # - if no other datasets for this event are true, turn off flag
  def destroy_live_data_flag
    datasets = LiveDataSet.where(:event_id => self.event_id)
    if datasets && !datasets.empty?
      has_live_data = datasets.select{|x| x.show_to_public}
      if (!has_live_data || has_live_data.empty?) || (has_live_data.length == 1 && has_live_data.first.id == self.id)
        self.event.has_live_data = false
        self.event.save
      end
    end

    # clear the menu cache
    I18n.available_locales.each do |locale|
      Rails.cache.delete("live_event_menu_json_#{locale}")
      Rails.cache.delete("event_menu_json_#{locale}")
      Rails.cache.delete("events_by_type_#{self.event.event_type_id}_#{locale}")
    end
  end
  
  def self.current_live_dataset(event_id)    
    where(:event_id => event_id, :show_to_public => true)
    .order("timestamp desc")
    .limit(1)
  end
  
end
