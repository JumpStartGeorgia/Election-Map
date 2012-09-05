class CreateLiveEvents < ActiveRecord::Migration
  def change
    create_table :live_events do |t|
      t.integer :event_id

      t.timestamps
    end
    add_index :live_events, :event_id
  end
end
