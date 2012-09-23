class ChangeLiveDatasetName < ActiveRecord::Migration
  def up
		remove_index :live_data_sets, :name => "idx_live_data_sets_on_event"

		rename_table :live_data_sets, :data_sets

		add_column :data_sets, :data_type, :string, :default => Datum::DATA_TYPE[:official]

		add_index :data_sets, [:event_id, :data_type, :show_to_public, :timestamp], :name => "idx_data_sets_on_event"

  end

  def down
		remove_index :data_sets, :name => "idx_data_sets_on_event"
		remove_column :data_sets, :data_type, :string

		rename_table :data_sets, :live_data_sets

		add_index :live_data_sets, [:event_id, :show_to_public, :timestamp], :name => "idx_live_data_sets_on_event"

  end
end
