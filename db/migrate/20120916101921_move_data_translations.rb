class MoveDataTranslations < ActiveRecord::Migration
  def up
    connection = ActiveRecord::Base.connection()
    puts "moving en data fields"
    connection.execute("update data as d, datum_translations as dt
    set d.en_common_id = dt.common_id, d.en_common_name = dt.common_name
    where d.id = dt.datum_id
    and dt.locale = 'en'")    

    puts "moving ka data fields"
    connection.execute("update data as d, datum_translations as dt
    set d.ka_common_id = dt.common_id, d.ka_common_name = dt.common_name
    where d.id = dt.datum_id
    and dt.locale = 'ka'")    
  end

  def down
    # delete all translation values
    connection = ActiveRecord::Base.connection()
    connection.execute("update data set en_common_id = null, en_common_name = null, ka_common_id = null, ka_common_name = null")          
  end
end
