class RemoveLocalesTable < ActiveRecord::Migration
  def up
		drop_table :locales
  end

  def down
    create_table :locales do |t|
      t.string :language
      t.string :name

      t.timestamps
    end
  end
end
