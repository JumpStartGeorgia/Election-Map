class RecreateNewsTables < ActiveRecord::Migration
  def up
		# tables got made in wrong encoding
		# delete what was there before
		if table_exists?(:news)
		  remove_index :news, :news_type
		  remove_index :news, :date_posted
		  remove_index :news, :data_archive_folder
		  drop_table :news
		  News.drop_translation_table!
		end

		# re-create
    create_table :news do |t|
      t.string :news_type
      t.datetime :date_posted
      t.string :data_archive_folder

      t.timestamps
    end
    add_index :news, :news_type
    add_index :news, :date_posted
    add_index :news, :data_archive_folder
    News.create_translation_table! :description => :text
  end

  def down
		if table_exists?(:news)
		  remove_index :news, :news_type
		  remove_index :news, :date_posted
		  remove_index :news, :data_archive_folder
		  drop_table :news
		  News.drop_translation_table!
		end
  end
end
