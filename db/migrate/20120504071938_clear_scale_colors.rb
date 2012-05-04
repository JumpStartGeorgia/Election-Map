class ClearScaleColors < ActiveRecord::Migration
  def change
		# lets keep existing color value in new column
		add_column :indicator_scales, :color_old, :string

		# now move the existing color to the new field
		IndicatorScale.where("color is not null").each do |scale|
			if !scale.color.nil?
				scale.color_old = scale.color
				scale.color = nil
				scale.save
			end
		end
  end
end
