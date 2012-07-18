# encoding: utf-8

class ChangeIndTypeName < ActiveRecord::Migration
  def up
    # change name from political results to overall results
    its = IndicatorTypeTranslation.where(:indicator_type_id => 2)
    its.each do |it|
      if it.locale == "en"
        it.name = "Overall Results"
      elsif it.locale == "ka"
        it.name = "საერთო შედეგები"
      end
      it.save
    end
  end

  def down
    its = IndicatorTypeTranslation.where(:indicator_type_id => 2)
    its.each do |it|
      if it.locale == "en"
        it.name = "Political Results"
      elsif it.locale == "ka"
        it.name = "პოლიტიკური შედეგები"
      end
      it.save
    end
  end
end
