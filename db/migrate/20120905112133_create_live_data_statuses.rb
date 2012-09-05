class CreateLiveDataStatuses < ActiveRecord::Migration
  def change
    create_table :live_data_statuses do |t|
      t.integer :live_model
      t.integer :inactive_model

      t.timestamps
    end

		add_index :live_data_statuses, :live_model
		add_index :live_data_statuses, :inactive_model
  end
end
