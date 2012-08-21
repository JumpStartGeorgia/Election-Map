class NewsTranslation < ActiveRecord::Base
  attr_accessible :news_id, :description, :locale
  belongs_to :news

  validates :description, :locale, :presence => true
  # this will always call validation to fail due to the translations being 
  # created while the page is created.  probably way to fix
#  validates :news_id, :presence => true  

end
