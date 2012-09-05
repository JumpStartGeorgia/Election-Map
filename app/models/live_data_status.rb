class LiveDataStatus < ActiveRecord::Base

  attr_accessible :live_model, :inactive_model

  validates :live_model, :inactive_model, :presence => true

	OBJECT_NAME = "LiveData"

	## last status item is the current status
	def self.current_status
		last
	end

	def live_model
		"#{OBJECT_NAME}#{read_attribute("live_model")}"
	end

	def inactive_model
		"#{OBJECT_NAME}#{read_attribute("inactive_model")}"
	end
end
