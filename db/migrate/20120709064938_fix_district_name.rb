class FixDistrictName < ActiveRecord::Migration
  def up
    # move data from value_old to value
    # if the data in value_old is a string (e.g., NULL), replace with null
    connection = ActiveRecord::Base.connection()
    connection.execute("update shape_translations set common_name = 'Tsalenjikha' where locale = 'en' and common_name = 'Tsalendjikha'")    
  end

  def down
		# do nothing
  end
end
