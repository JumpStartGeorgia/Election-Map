# encoding: utf-8
class FixIndTranslation < ActiveRecord::Migration
  def up
		# get all translation records
		trans = CoreIndicatorTranslation.where("name like 'გაუქმებული საარჩევნო ბიულეტინი%'")

		# from x-y%
		ranges = ['0-1','1-3','3-5']
		trans.select{|x| ranges.index{|y| !x.name.index(y).nil? }}.each do |x|
			x.name_abbrv = x.name_abbrv.gsub('გაუქმებული საარჩევნო ბიულეტინი', 'ბათილი ბიულეტენები')
			x.name = x.name.gsub('გაუქმებული საარჩევნო ბიულეტინი', 'უბნების რაოდენობა, სადაც ბათილი ბიულეტინები შეადგენს')
			x.description = x.description.gsub('გაუქმებული საარჩევნო ბიულეტინი', 'უბნების რაოდენობა, სადაც ბათილი ბიულეტინები შეადგენს')
			x.save
		end

		# > 5%
		trans.select{|x| x.name == 'გაუქმებული საარჩევნო ბიულეტინი > 5%'}.each do |x|
			x.name_abbrv = 'ბათილი ბიულეტენები > 5%'
			x.name = 'უბნების რაოდენობა, სადაც ბათილი ბიულეტინები > 5%'
			x.description = 'უბნების რაოდენობა, სადაც ბათილი ბიულეტინები > 5%'
			x.save
		end

		# (%)
		trans.select{|x| x.name == 'გაუქმებული საარჩევნო ბიულეტინი (%)'}.each do |x|
			x.name_abbrv = 'ბათილი ბიულეტენები (%)'
			x.name = 'ბათილი ბიულეტენები (%)'
			x.description = 'ბათილი ბიულეტენები (%)'
			x.save
		end

  end

  def down
		# get all translation records
		trans = CoreIndicatorTranslation.where("name like '%ბათილი ბიულეტენები%'")

		# from x-y%
		ranges = ['0-1','1-3','3-5']
		trans.select{|x| ranges.index{|y| !x.name.index(y).nil? }}.each do |x|
			x.name_abbrv = x.name_abbrv.gsub('ბათილი ბიულეტენები', 'გაუქმებული საარჩევნო ბიულეტინი')
			x.name = x.name.gsub('უბნების რაოდენობა, სადაც ბათილი ბიულეტინები შეადგენს', 'გაუქმებული საარჩევნო ბიულეტინი')
			x.description = x.description.gsub('უბნების რაოდენობა, სადაც ბათილი ბიულეტინები შეადგენს', 'გაუქმებული საარჩევნო ბიულეტინი')
			x.save
		end

		# > 5%
		trans.select{|x| x.name == 'უბნების რაოდენობა, სადაც ბათილი ბიულეტინები > 5%'}.each do |x|
			x.name_abbrv = 'გაუქმებული საარჩევნო ბიულეტინი > 5%'
			x.name = 'გაუქმებული საარჩევნო ბიულეტინი > 5%'
			x.description = 'გაუქმებული საარჩევნო ბიულეტინი > 5%'
			x.save
		end

		# (%)
		trans.select{|x| x.name == 'ბათილი ბიულეტენები (%)'}.each do |x|
			x.name_abbrv = 'გაუქმებული საარჩევნო ბიულეტინი (%)'
			x.name = 'გაუქმებული საარჩევნო ბიულეტინი (%)'
			x.description = 'გაუქმებული საარჩევნო ბიულეტინი (%)'
			x.save
		end
  end
end
