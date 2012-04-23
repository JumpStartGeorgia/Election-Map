class AddEventDate < ActiveRecord::Migration
  def change
    add_column :events, :event_date, :date
  end
end
