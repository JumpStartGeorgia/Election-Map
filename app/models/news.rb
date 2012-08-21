class News < ActiveRecord::Base
  translates :description

  has_many :news_translations, :dependent => :destroy
  accepts_nested_attributes_for :news_translations
  attr_accessible :news_type, :date_posted, :data_archive_folder, :news_translations_attributes
  attr_accessor :locale

  validates :news_type, :date_posted, :presence => true

	NEWS_TYPES =	{:data_archive => "Data Archive", :news => "News"}

  scope :data_archives, where(["news_type = ? and data_archive_folder is not null", NEWS_TYPES[:data_archive]])
  scope :recent, order("date_posted desc")

	# for pagination
	self.per_page = 10

end
