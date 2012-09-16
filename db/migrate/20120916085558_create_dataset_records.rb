class CreateDatasetRecords < ActiveRecord::Migration
  def up
    # for each event, create a dataset record and add the id to the data records
    Event.all.each do |event|
      puts "processing event #{event.name}"
      # create dataset
      dataset = DataSet.new
      dataset.event_id = event.id
      dataset.data_type = Datum::DATA_TYPE[:official]
      dataset.timestamp = event.event_date.next_month # it takes 3 weeks to make data official
      dataset.save
      
      # add dataset id to data
      connection = ActiveRecord::Base.connection()
      sql = "update data set data_set_id = #{dataset.id} "
      sql << "where indicator_id in (select id from indicators where event_id = #{event.id})"
      connection.execute(sql)          
    end
  end

  def down
    # delete all dataset values
      connection = ActiveRecord::Base.connection()
      connection.execute("update data set data_set_id = null")          
  end
end
