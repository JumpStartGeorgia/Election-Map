class AddIndicatorFields < ActiveRecord::Migration
  def change
    add_column :indicator_translations, :description, :text
    add_column :indicators, :number_format, :string
  end
end
