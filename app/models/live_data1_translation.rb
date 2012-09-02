class LiveData1Translation < ActiveRecord::Base
  attr_accessible :live_data1_id, :common_id, :common_name, :locale
  belongs_to :live_data1

  validates :common_id, :common_name, :locale, :presence => true


	def to_hash
		hash = Hash.new
		self.attributes.each do |k,v|
			hash[k] = v
		end
	end
end
