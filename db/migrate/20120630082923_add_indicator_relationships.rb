class AddIndicatorRelationships < ActiveRecord::Migration
  def up
    EventIndicatorRelationship.delete_all

    #IMPORTANT - must include id of self indicator in relation so it will
    # be included in the relationship

		# group all voter list indicators together
		cit1 = CoreIndicatorTranslation.where(:name_abbrv => "Avg. Age", :locale => "en")
		cit2 = CoreIndicatorTranslation.where(:name_abbrv => "85-99", :locale => "en")
		cit3 = CoreIndicatorTranslation.where(:name_abbrv => "Above 100", :locale => "en")
		cit4 = CoreIndicatorTranslation.where(:name_abbrv => "Duplications", :locale => "en")
		cit5 = CoreIndicatorTranslation.where(:name_abbrv => "TV", :locale => "en")
		events = Event.where(:event_type_id => 2)
		events.each do |event|
			# avg. age
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit1.first.core_indicator_id, 
		    :related_core_indicator_id => cit1.first.core_indicator_id, :sort_order => 1)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit1.first.core_indicator_id, 
		    :related_core_indicator_id => cit2.first.core_indicator_id, :sort_order => 2)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit1.first.core_indicator_id, 
		    :related_core_indicator_id => cit3.first.core_indicator_id, :sort_order => 3)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit1.first.core_indicator_id, 
		    :related_core_indicator_id => cit4.first.core_indicator_id, :sort_order => 4)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit1.first.core_indicator_id, 
		    :related_core_indicator_id => cit5.first.core_indicator_id, :sort_order => 5)
			# 85-99
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit2.first.core_indicator_id, 
		    :related_core_indicator_id => cit1.first.core_indicator_id, :sort_order => 1)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit2.first.core_indicator_id, 
		    :related_core_indicator_id => cit2.first.core_indicator_id, :sort_order => 2)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit2.first.core_indicator_id, 
		    :related_core_indicator_id => cit3.first.core_indicator_id, :sort_order => 3)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit2.first.core_indicator_id, 
		    :related_core_indicator_id => cit4.first.core_indicator_id, :sort_order => 4)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit2.first.core_indicator_id, 
		    :related_core_indicator_id => cit5.first.core_indicator_id, :sort_order => 5)
			# above 100
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit3.first.core_indicator_id, 
		    :related_core_indicator_id => cit1.first.core_indicator_id, :sort_order => 1)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit3.first.core_indicator_id, 
		    :related_core_indicator_id => cit2.first.core_indicator_id, :sort_order => 2)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit3.first.core_indicator_id, 
		    :related_core_indicator_id => cit3.first.core_indicator_id, :sort_order => 3)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit3.first.core_indicator_id, 
		    :related_core_indicator_id => cit4.first.core_indicator_id, :sort_order => 4)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit3.first.core_indicator_id, 
		    :related_core_indicator_id => cit5.first.core_indicator_id, :sort_order => 5)
			# dups
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit4.first.core_indicator_id, 
		    :related_core_indicator_id => cit1.first.core_indicator_id, :sort_order => 1)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit4.first.core_indicator_id, 
		    :related_core_indicator_id => cit2.first.core_indicator_id, :sort_order => 2)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit4.first.core_indicator_id, 
		    :related_core_indicator_id => cit3.first.core_indicator_id, :sort_order => 3)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit4.first.core_indicator_id, 
		    :related_core_indicator_id => cit4.first.core_indicator_id, :sort_order => 4)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit4.first.core_indicator_id, 
		    :related_core_indicator_id => cit5.first.core_indicator_id, :sort_order => 5)
			# total voters
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit5.first.core_indicator_id, 
		    :related_core_indicator_id => cit1.first.core_indicator_id, :sort_order => 1)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit5.first.core_indicator_id, 
		    :related_core_indicator_id => cit2.first.core_indicator_id, :sort_order => 2)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit5.first.core_indicator_id, 
		    :related_core_indicator_id => cit3.first.core_indicator_id, :sort_order => 3)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit5.first.core_indicator_id, 
		    :related_core_indicator_id => cit4.first.core_indicator_id, :sort_order => 4)
		  EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit5.first.core_indicator_id, 
		    :related_core_indicator_id => cit5.first.core_indicator_id, :sort_order => 5)
		end

		##############################
		# party results summary with total turnout #
    citTT = CoreIndicatorTranslation.where(:name_abbrv => "TT#", :locale => "en")
    cit2 = CoreIndicatorTranslation.where(:name_abbrv => "TT%", :locale => "en")
		events = Event.where(:event_type_id => 1)
		events.each do |event|
			# summary => TT#
			EventIndicatorRelationship.create(:event_id => event.id, 
				:indicator_type_id => 2, 
			  :related_indicator_type_id => 2, :sort_order => 1)
			EventIndicatorRelationship.create(:event_id => event.id, 
				:indicator_type_id => 2, 
			  :related_core_indicator_id => citTT.first.core_indicator_id, :sort_order => 2)

			# TT# => TT%
			EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => citTT.first.core_indicator_id, 
			  :related_core_indicator_id => citTT.first.core_indicator_id, :sort_order => 1)
			EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => citTT.first.core_indicator_id, 
			  :related_core_indicator_id => cit2.first.core_indicator_id, :sort_order => 2)

			# TT% => TT#
			EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit2.first.core_indicator_id, 
			  :related_core_indicator_id => citTT.first.core_indicator_id, :sort_order => 1)
			EventIndicatorRelationship.create(:event_id => event.id, 
				:core_indicator_id => cit2.first.core_indicator_id, 
			  :related_core_indicator_id => cit2.first.core_indicator_id, :sort_order => 2)
		end

		##############################
		# VPMs
    cit1 = CoreIndicatorTranslation.where(:name_abbrv => "VPM 08:00-12:00", :locale => "en")
    cit2 = CoreIndicatorTranslation.where(:name_abbrv => "VPM 12:00-17:00", :locale => "en")
    cit3 = CoreIndicatorTranslation.where(:name_abbrv => "VPM 17:00-20:00", :locale => "en")
    cit4 = CoreIndicatorTranslation.where(:name_abbrv => "VPM 12:00-15:00", :locale => "en")
    cit5 = CoreIndicatorTranslation.where(:name_abbrv => "VPM 15:00-20:00", :locale => "en")
		events = Event.where(:event_type_id => 1)
		events.each do |event|
			# test if event has the 12-15 vpm
			hasVPM = false
			event.indicators.each do |ind|
				if ind.core_indicator_id == cit4.first.core_indicator_id
					hasVPM = true 
					break
				end
			end

			# there are two sets of VPMs - one for precinct and then one for all other shapes
			(0..1).each do |i|
				if hasVPM
					# use the 15:00 times
					# vpm 08-12
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit1[i].core_indicator_id, 
						:related_core_indicator_id => cit1[i].core_indicator_id, :sort_order => 1)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit1[i].core_indicator_id, 
						:related_core_indicator_id => cit4[i].core_indicator_id, :sort_order => 2)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit1[i].core_indicator_id, 
						:related_core_indicator_id => cit5[i].core_indicator_id, :sort_order => 3)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit1[i].core_indicator_id, 
						:related_core_indicator_id => citTT.first.core_indicator_id, :sort_order => 4)
					# vpm 12-15
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit4[i].core_indicator_id, 
						:related_core_indicator_id => cit1[i].core_indicator_id, :sort_order => 1)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit4[i].core_indicator_id, 
						:related_core_indicator_id => cit4[i].core_indicator_id, :sort_order => 2)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit4[i].core_indicator_id, 
						:related_core_indicator_id => cit5[i].core_indicator_id, :sort_order => 3)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit4[i].core_indicator_id, 
						:related_core_indicator_id => citTT.first.core_indicator_id, :sort_order => 4)
					# vpm 15-20
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit5[i].core_indicator_id, 
						:related_core_indicator_id => cit1[i].core_indicator_id, :sort_order => 1)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit5[i].core_indicator_id, 
						:related_core_indicator_id => cit4[i].core_indicator_id, :sort_order => 2)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit5[i].core_indicator_id, 
						:related_core_indicator_id => cit5[i].core_indicator_id, :sort_order => 3)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit5[i].core_indicator_id, 
						:related_core_indicator_id => citTT.first.core_indicator_id, :sort_order => 4)
				else
					# use the 17:00 times
					# vpm 08-12
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit1[i].core_indicator_id, 
						:related_core_indicator_id => cit1[i].core_indicator_id, :sort_order => 1)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit1[i].core_indicator_id, 
						:related_core_indicator_id => cit2[i].core_indicator_id, :sort_order => 2)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit1[i].core_indicator_id, 
						:related_core_indicator_id => cit3[i].core_indicator_id, :sort_order => 3)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit1[i].core_indicator_id, 
						:related_core_indicator_id => citTT.first.core_indicator_id, :sort_order => 4)
					# vpm 12-17
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit2[i].core_indicator_id, 
						:related_core_indicator_id => cit1[i].core_indicator_id, :sort_order => 1)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit2[i].core_indicator_id, 
						:related_core_indicator_id => cit2[i].core_indicator_id, :sort_order => 2)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit2[i].core_indicator_id, 
						:related_core_indicator_id => cit3[i].core_indicator_id, :sort_order => 3)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit2[i].core_indicator_id, 
						:related_core_indicator_id => citTT.first.core_indicator_id, :sort_order => 4)
					# vpm 17-20
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit3[i].core_indicator_id, 
						:related_core_indicator_id => cit1[i].core_indicator_id, :sort_order => 1)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit3[i].core_indicator_id, 
						:related_core_indicator_id => cit2[i].core_indicator_id, :sort_order => 2)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit3[i].core_indicator_id, 
						:related_core_indicator_id => cit3[i].core_indicator_id, :sort_order => 3)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => cit3[i].core_indicator_id, 
						:related_core_indicator_id => citTT.first.core_indicator_id, :sort_order => 4)
				end
			end
		end

		##############################
		# political parties/members => self and TT#
		events = Event.where(:event_type_id => 1)
		events.each do |event|
			event.indicators.where(:shape_type_id => 1).each do |indicator|
				if indicator.core_indicator.indicator_type_id == 2 # political party
					# create relationship
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => indicator.core_indicator_id, 
						:related_core_indicator_id => indicator.core_indicator_id, :sort_order => 1)
					EventIndicatorRelationship.create(:event_id => event.id, 
						:core_indicator_id => indicator.core_indicator_id, 
						:related_core_indicator_id => citTT.first.core_indicator_id, :sort_order => 2)
				end
			end			
		end		


  end

  def down
    EventIndicatorRelationship.delete_all
  end
end
