class MoveTranslationFields < ActiveRecord::Migration
  def up
    add_column :data, :common_id_en, :string
    add_column :data, :common_name_en, :string
    add_column :data, :common_id_ka, :string
    add_column :data, :common_name_ka, :string
    add_column :shapes, :common_id_en, :string
    add_column :shapes, :common_name_en, :string
    add_column :shapes, :common_id_ka, :string
    add_column :shapes, :common_name_ka, :string
    
    add_index :data, [:common_id_en, :common_name_en]
    add_index :data, [:common_id_ka, :common_name_ka]
    add_index :shapes, [:common_id_en, :common_name_en]
    add_index :shapes, [:common_id_ka, :common_name_ka]
  end

  def down
    remove_index :data, [:common_id_en, :common_name_en]
    remove_index :data, [:common_id_ka, :common_name_ka]
    remove_index :shapes, [:common_id_en, :common_name_en]
    remove_index :shapes, [:common_id_ka, :common_name_ka]
    
    remove_column :data, :common_id_en, :string
    remove_column :data, :common_name_en, :string
    remove_column :data, :common_id_ka, :string
    remove_column :data, :common_name_ka, :string
    remove_column :shapes, :common_id_en, :string
    remove_column :shapes, :common_name_en, :string
    remove_column :shapes, :common_id_ka, :string
    remove_column :shapes, :common_name_ka, :string
  end
end
