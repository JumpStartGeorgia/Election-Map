class AddColorToCoreIndicator < ActiveRecord::Migration
  def change
    add_column :core_indicators, :color, :string
  end
end
