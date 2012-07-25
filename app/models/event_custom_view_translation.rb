class EventCustomViewTranslation < ActiveRecord::Base
  attr_accessible :event_custom_view_id, :note, :locale
  belongs_to :event_custom_view

  validates :note, :locale, :presence => true
  # this will always call validation to fail due to the translations being
  # created while the event custom view is created.  probably way to fix
#  validates :event_custom_view_id, :presence => true

end
