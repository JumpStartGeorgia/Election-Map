class DatumTranslation < ActiveRecord::Base
  attr_accessible :datum_id, :common_id, :common_name, :locale
  belongs_to :datum

  validates :common_id, :common_name, :locale, :presence => true
  # this will always call validation to fail due to the translations being
  # created while the datum is created.  probably way to fix
#  validates :datum_id, :presence => true


	def to_hash
		hash = Hash.new
		self.attributes.each do |k,v|
			hash[k] = v
		end
	end
end
