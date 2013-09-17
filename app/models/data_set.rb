class DataSet < ActiveRecord::Base
  belongs_to :event
  has_many :data, :dependent => :destroy

  attr_accessible :event_id, :data_type, :precincts_completed, :precincts_total, :timestamp, :show_to_public

  validates :event_id, :data_type, :timestamp, :presence => true
  validates :precincts_completed, :precincts_total, :presence => true, :if => "data_type == Datum::DATA_TYPE[:live]"

  after_save :update_data_flag
  before_destroy :destroy_data_flag

	###################################
	## special gets for attributes
	###################################
  def precincts_percentage
    ActionController::Base.helpers.number_to_percentage(read_attribute(:precincts_completed).to_f/read_attribute(:precincts_total)*100) if read_attribute(:precincts_completed) && read_attribute(:precincts_total)
  end
  def precincts_completed
    if read_attribute(:precincts_completed)
			return ActionController::Base.helpers.number_with_delimiter(read_attribute(:precincts_completed))
    end
  end
  def precincts_total
    if read_attribute(:precincts_total)
			return ActionController::Base.helpers.number_with_delimiter(read_attribute(:precincts_total))
    end
  end

  def self.current_dataset(event_id, data_type)
    where(:event_id => event_id, :show_to_public => true, :data_type => data_type)
    .order("timestamp desc")
    .limit(1)
  end


  def self.ordered
    joins(:event)
    .order("events.event_date desc, data_sets.timestamp desc")
  end


	################################
	## before/after filter functions
	################################
  # - if show to pulic is true, turn on the has_xxx_data for this event
  # - if show public is false, and no other datasets for this event are true, turn off flag
  # - if data type = official and is public, turn off all existing live datasets 
  def update_data_flag
    DataSet.transaction do 
      if self.show_to_public
        self.event.has_live_data = true if self.data_type == Datum::DATA_TYPE[:live]
        self.event.has_official_data = true if self.data_type == Datum::DATA_TYPE[:official]
        self.event.save

        # if this is official and live events existed, turn them off
        if self.data_type == Datum::DATA_TYPE[:official]
          live_sets = DataSet.where(:event_id => self.event_id, :data_type => Datum::DATA_TYPE[:live], :show_to_public => true)
          if live_sets.present?
            live_sets.each do |set|
              set.show_to_public = false
              set.save
            end
            # turn off event has_live_data flag
			      self.event.has_live_data = false
            self.event.save
          end
        end
      else
        datasets = DataSet.where(:event_id => self.event_id)
        if datasets && !datasets.empty?
          has_live_data = datasets.select{|x| x.show_to_public && x.data_type == Datum::DATA_TYPE[:live]}
          has_official_data = datasets.select{|x| x.show_to_public && x.data_type == Datum::DATA_TYPE[:official]}
          if !has_live_data || has_live_data.empty?
				    self.event.has_live_data = false
            self.event.save
          end
          if !has_official_data || has_official_data.empty?
				    self.event.has_official_data = false
            self.event.save
          end
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
  def destroy_data_flag
    datasets = DataSet.where(:event_id => self.event_id)
    if datasets && !datasets.empty?
      has_live_data = datasets.select{|x| x.show_to_public && x.data_type == Datum::DATA_TYPE[:live]}
      has_official_data = datasets.select{|x| x.show_to_public && x.data_type == Datum::DATA_TYPE[:official]}
      if (!has_live_data || has_live_data.empty?) || (has_live_data.length == 1 && has_live_data.first.id == self.id)
			  self.event.has_live_data = false
        self.event.save
      end
      if (!has_official_data || has_official_data.empty?) ||
					(has_official_data.length == 1 && has_official_data.first.id == self.id)
			  self.event.has_official_data = false
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

	################################
	## override destroy fn so it uses delete and is faster
	################################
  def destroy
Rails.logger.debug "************** data set overriden destroy method, deleting all data records"
		Datum.delete_all(:data_set_id => self.id)
Rails.logger.debug "************** data set overriden destroy method, deleting dataset"
		DataSet.delete(self.id)
	end

end
