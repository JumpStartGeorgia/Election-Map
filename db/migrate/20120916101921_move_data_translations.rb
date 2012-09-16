class MoveDataTranslations < ActiveRecord::Migration
  def up
    # for each event, create a dataset record and add the id to the data records
    Event.all.each do |event|
      puts "processing event #{event.name}"

      connection = ActiveRecord::Base.connection()
      sql = "update data set data_set_id = #{dataset.id} "
      sql << "where indicator_id in (select id from indicators where event_id = #{event.id})"
      connection.execute(sql)          
    end
  end

  def down
    # delete all translation values
      connection = ActiveRecord::Base.connection()
      connection.execute("update data set en_common_id = null, en_common_name = null, ka_common_id = null, ka_common_name = null")          
  end
end
