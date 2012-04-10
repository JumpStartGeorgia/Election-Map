class Page < ActiveRecord::Base
  translates :title, :description

  has_many :page_translations, :dependent => :destroy
  accepts_nested_attributes_for :page_translations
  attr_accessible :name, :page_translations_attributes
  attr_accessor :locale

  validates :name, :presence => true
  
  scope :l10n , joins(:page_translations).where('locale = ?',I18n.locale)

end
