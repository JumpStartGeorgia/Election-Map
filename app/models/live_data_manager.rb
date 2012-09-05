class LiveDataManager
	include ActiveAttr::Model

	## get the object of the current live data model
	def self.live_data_object
		l = LiveDataStatus.current_status
		if l
			return Object::const_get(l.live_model)
		else
			return nil
		end
	end

	## get the object of the current inactive data model
	def self.inactive_data_object
		l = LiveDataStatus.current_status
		if l
			return Object::const_get(l.inactive_model)
		else
			return nil
		end
	end


	def self.test
		puts "live test = #{live_data_object.test}"
		puts "inactive test = #{inactive_data_object.test}"
	end
end
