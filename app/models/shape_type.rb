class ShapeType < ActiveRecord::Base
  translates :name_singular, :name_plural
  has_ancestry

  has_many :indicators
  has_many :shapes
  has_many :shape_type_translations, :dependent => :destroy
  accepts_nested_attributes_for :shape_type_translations
  attr_accessible :id, :ancestry, :shape_type_translations_attributes
  attr_accessor :locale

  scope :l10n , joins(:shape_type_translations).where('locale = ?',I18n.locale)
  scope :by_name , order('name').l10n


end
