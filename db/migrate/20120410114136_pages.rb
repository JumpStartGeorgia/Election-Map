class Pages < ActiveRecord::Migration
  def up
    create_table :pages do |t|
      t.string :name

      t.timestamps
    end
    Page.create_translation_table! :description => :text
    add_index :pages, :name
  end

  def down
    drop_table :pages
    Page.drop_translation_table!    
    remove_index :pages, :name
  end
end
