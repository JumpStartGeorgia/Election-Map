class CreateLiveDataSets < ActiveRecord::Migration
  def change
    create_table :live_data_sets do |t|
      t.integer :event_id
      t.integer :precincts_completed
      t.integer :precincts_total
      t.datetime :timestamp
      t.boolean :show_to_public, :default => false

      t.timestamps
    end

		add_index :live_data_sets, [:event_id, :show_to_public, :timestamp], :name => "idx_live_data_sets_on_event"
  end
end
