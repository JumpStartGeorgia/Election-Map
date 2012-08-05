class MoveTransData < ActiveRecord::Migration
  def up

    # move data from value_old to value
    # if the data in value_old is a string (e.g., NULL), replace with null
    connection = ActiveRecord::Base.connection()
    puts "moving en data fields"
    connection.execute("update data as d, datum_translations as dt
    set d.common_id_en = dt.common_id, d.common_name_en = dt.common_name
    where d.id = dt.datum_id
    and dt.locale = 'en'")    

    puts "moving ka data fields"
    connection.execute("update data as d, datum_translations as dt
    set d.common_id_ka = dt.common_id, d.common_name_ka = dt.common_name
    where d.id = dt.datum_id
    and dt.locale = 'ka'")    

    puts "moving en shape fields"
    connection.execute("update shapes as s, shape_translations as st
    set s.common_id_en = st.common_id, s.common_name_en = st.common_name
    where s.id = st.shape_id
    and st.locale = 'en'")    

    puts "moving ka shape fields"
    connection.execute("update shapes as s, shape_translations as st
    set s.common_id_ka = st.common_id, s.common_name_ka = st.common_name
    where s.id = st.shape_id
    and st.locale = 'ka'")    
  end

  def down
    # do nothing
  end
end
