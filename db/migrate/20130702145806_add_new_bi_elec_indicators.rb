# encoding: UTF-8
class AddNewBiElecIndicators < ActiveRecord::Migration
  def up
    init_grp_id = nil

    # Initiative Group
    core = CoreIndicator.create(:indicator_type_id => 2, :number_format => '%', :color => '#e0e4bf')
    core.core_indicator_translations.create(:locale => 'en', :name => 'Initiative Group',
      :name_abbrv => 'Init Grp', :description => 'Vote share Initiative Group (%)')
    core.core_indicator_translations.create(:locale => 'ka', :name => 'საინიციატივო ჯგუფი',
      :name_abbrv => 'საინიციატივო ჯგუფი', :description => 'ხმების გადანაწილება, საინიციატივო ჯგუფი (%)')

    init_grp_id = core.id

    # Ioseb Manjavidze
    core = CoreIndicator.create(:indicator_type_id => 2, :number_format => '%')
    core.parent_id = init_grp_id
    core.save
    core.core_indicator_translations.create(:locale => 'en', :name => 'Ioseb Manjavidze',
      :name_abbrv => 'Manjavidze', :description => 'Vote share Ioseb Manjavidze (%)')
    core.core_indicator_translations.create(:locale => 'ka', :name => 'იოსებ მანჯავიძე',
      :name_abbrv => 'მანჯავიძე', :description => 'ხმების გადანაწილება, იოსებ მანჯავიძე (%)')

    # Zviad Chitishvili
    core = CoreIndicator.create(:indicator_type_id => 2, :number_format => '%')
    core.parent_id = init_grp_id
    core.save
    core.core_indicator_translations.create(:locale => 'en', :name => 'Zviad Chitishvili',
      :name_abbrv => 'Chitishvili', :description => 'Vote share Zviad Chitishvili (%)')
    core.core_indicator_translations.create(:locale => 'ka', :name => 'ზვიად ჩიტიშვილი',
      :name_abbrv => 'ჩიტიშვილი', :description => 'ხმების გადანაწილება, ზვიად ჩიტიშვილი (%)')

    # Roman Robakidze	
    core = CoreIndicator.create(:indicator_type_id => 2, :number_format => '%')
    core.parent_id = init_grp_id
    core.save
    core.core_indicator_translations.create(:locale => 'en', :name => 'Roman Robakidze',
      :name_abbrv => 'Roman Robakidze', :description => 'Vote share Roman Robakidze (%)')
    core.core_indicator_translations.create(:locale => 'ka', :name => 'რომან რობაქიძე',
      :name_abbrv => 'რობაქიძე', :description => 'ხმების გადანაწილება, რომან რობაქიძე (%)')

    # Zurab Mskhvilidze
    core = CoreIndicator.create(:indicator_type_id => 2, :number_format => '%')
    core.parent_id = init_grp_id
    core.save
    core.core_indicator_translations.create(:locale => 'en', :name => 'Roman Robakidze',
      :name_abbrv => 'Zurab Mskhvilidze', :description => 'Vote share Zurab Mskhvilidze (%)')
    core.core_indicator_translations.create(:locale => 'ka', :name => 'ზურაბ მსხვილიძე',
      :name_abbrv => 'მსხვილიძე', :description => 'ხმების გადანაწილება, ზურაბ მსხვილიძე (%)')

  end

  def down
    # delete the core indicators
    names = ['Initiative Group', 'საინიციატივო ჯგუფი', 'Ioseb Manjavidze', 'იოსებ მანჯავიძე', 'Zviad Chitishvili', 'ზვიად ჩიტიშვილი', 'Roman Robakidze', 'რომან რობაქიძე', 'Roman Robakidze', 'ზურაბ მსხვილიძე']
    inds = CoreIndicatorTranslation.where(:name => names)
    CoreIndicator.where(:id => inds.map{|x| x.core_indicator_id}).destroy_all
  end
end
