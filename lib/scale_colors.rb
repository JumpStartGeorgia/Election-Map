module ScaleColors
	# get an array of colors for a provided color name and number of scale colors
	def self.get_colors(color_name, number_colors)
		if color_name.nil? || number_colors.nil?
			return nil
		else
			c = colors[color_name]
			if c.nil?
				return nil
			else
				return c[number_colors]
			end
		end
	end

	# get an array of color names
	def self.get_color_names()
		return nil
	end

private

	def colors
		colors = Hash[
			"red" => Hash[
						3 => ["#FEE8C8", "#FDBB84", "#E34A33"],
						4 => ["#FEF0D9", "#FDCC8A", "#FC8D59", "#D7301F"],
						5 => ["#FEF0D9", "#FDCC8A", "#FC8D59", "#E34A33", "#B30000"],
						6 => ["#FEF0D9", "#FDD49E", "#FDBB84", "#FC8D59", "#E34A33", "#B30000"],
						7 => ["#FEF0D9", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#990000"],
						8 => ["#FFF7EC", "#FEE8C8", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#990000"],
						9 => ["#FFF7EC", "#FEE8C8", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#B30000", "#7F0000"]
			],
			"green" => Hash[
						3 => ["#0EE8C8", "#FDBB84", "#E34A33"],
						4 => ["#0EF0D9", "#FDCC8A", "#FC8D59", "#D7301F"],
						5 => ["#0EF0D9", "#FDCC8A", "#FC8D59", "#E34A33", "#B30000"],
						6 => ["#0EF0D9", "#FDD49E", "#FDBB84", "#FC8D59", "#E34A33", "#B30000"],
						7 => ["#0EF0D9", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#990000"],
						8 => ["#0FF7EC", "#FEE8C8", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#990000"],
						9 => ["#0FF7EC", "#FEE8C8", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#B30000", "#7F0000"]
			]
		]
		return colors
	end

end
