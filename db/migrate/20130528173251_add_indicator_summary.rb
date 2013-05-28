class AddIndicatorSummary < ActiveRecord::Migration
  def change
    add_column :core_indicator_translations, :summary, :text
  end
end
