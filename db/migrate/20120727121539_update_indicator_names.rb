# encoding: utf-8

class UpdateIndicatorNames < ActiveRecord::Migration
  def up
		# now that there is more room for the indicator names, lets make them understandable

		# english first
		core_indicator_translations = CoreIndicatorTranslation.where(:locale => 'en')
		# avg age
    cit = core_indicator_translations.select{|x| x.core_indicator_id == 1}.first
    cit.name_abbrv = 'Average Age'
		cit.save
		# 85-99
    cit = core_indicator_translations.select{|x| x.core_indicator_id == 13}.first
    cit.name_abbrv = '85-99 Years Old'
		cit.save
		# > 99
    cit = core_indicator_translations.select{|x| x.core_indicator_id == 14}.first
    cit.name_abbrv = 'Over 99 Years Old'
		cit.save
		# TT#
    cit = core_indicator_translations.select{|x| x.core_indicator_id == 15}.first
    cit.name_abbrv = 'Total Turnout (#)'
		cit.save
		# TT%
    cit = core_indicator_translations.select{|x| x.core_indicator_id == 16}.first
    cit.name_abbrv = 'Total Turnout (%)'
		cit.save
		# TV
    cit = core_indicator_translations.select{|x| x.core_indicator_id == 17}.first
    cit.name_abbrv = 'Total Voters'
		cit.save
		# CDM
    cit = core_indicator_translations.select{|x| x.core_indicator_id == 20}.first
    cit.name = 'Christian-Democratic Movement'
    cit.description = 'Vote share Christian-Democratic Movement (%)'
		cit.save

		########################
		# georgian
		core_indicator_translations = CoreIndicatorTranslation.where(:locale => 'ka')
		# 85-99
    cit = core_indicator_translations.select{|x| x.core_indicator_id == 13}.first
    cit.name_abbrv = '85-99 წლის'
		cit.save
		# > 99
    cit = core_indicator_translations.select{|x| x.core_indicator_id == 14}.first
    cit.name_abbrv = 'გამო 99 წლის'
		cit.save
		# CDM
    cit = core_indicator_translations.select{|x| x.core_indicator_id == 20}.first
    cit.name = 'ქრისტიანულ-დემოკრატიული მოძრაობა'
    cit.description = 'ქრისტიანულ-დემოკრატიული მოძრაობა (%)'
		cit.save
  end

  def down
		# do nothing
  end
end
