class UniqueShapeName < ActiveRecord::Base
  translates :common_id, :common_name, :summary

  has_many :unique_shape_name_translations, :dependent => :destroy
  accepts_nested_attributes_for :unique_shape_name_translations
  attr_accessible :shape_type_id, :unique_shape_name_translations_attributes

  validates :shape_type_id, :presence => true


  def self.sorted
    with_translations(I18n.locale).order("unique_shape_name_translations.common_name asc")
  end

  def self.by_shape_types(ids)
    where(:shape_type_id => ids)
  end

  def self.get_districts_by_hash
    by_shape_types([3,7]).sorted
  end
end
