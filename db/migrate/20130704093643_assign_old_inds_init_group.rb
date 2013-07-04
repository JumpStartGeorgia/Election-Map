class AssignOldIndsInitGroup < ActiveRecord::Migration
  require 'json_cache'
  def up
    # get init group
    ind = CoreIndicatorTranslation.where(:locale => 'en', :name => 'Initiative Group')
    if ind.present?
      names = ['Arkadi (Badri) Patarkatsishvili', 'Giorgi (Gia) Maisashvili', 'Irina Sarishvili-Chanturia']
      inds = CoreIndicatorTranslation.where(:name => names, :locale => 'en')
      
      if inds.present?
        CoreIndicator.where(:id => inds.map{|x| x.core_indicator_id}).each do |i|
          i.parent_id = ind.first.core_indicator_id
          i.color = nil
          i.save
        end

        JsonCache.clear_all
      else
        puts 'COULD NOT FIND INDICATORS TO UPDATE'
      end

    else
      puts 'COULD NOT FIND THE INITIATIVE GROUP INDICATOR'
    end
  end

  def down
    # do nothing
  end
end
