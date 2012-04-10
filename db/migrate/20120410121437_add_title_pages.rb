class AddTitlePages < ActiveRecord::Migration
  def change
    add_column :page_translations, :title, :string
  end
end
