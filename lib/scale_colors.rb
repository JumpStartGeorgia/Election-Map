module ScaleColors
	# get an array of colors for a provided color name and number of scale colors
	def self.get_colors(color_name, number_colors)
		if color_name.nil? || number_colors.nil?
			return nil
		else
			c = ScaleColors.colors[color_name]
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

  # colors are from http://colorbrewer2.org/
	def self.colors
		colors = Hash[
			"OrRd" => Hash[
						3 => ["#FEE8C8", "#FDBB84", "#E34A33"],
						4 => ["#FEF0D9", "#FDCC8A", "#FC8D59", "#D7301F"],
						5 => ["#FEF0D9", "#FDCC8A", "#FC8D59", "#E34A33", "#B30000"],
						6 => ["#FEF0D9", "#FDD49E", "#FDBB84", "#FC8D59", "#E34A33", "#B30000"],
						7 => ["#FEF0D9", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#990000"],
						8 => ["#FFF7EC", "#FEE8C8", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#990000"],
						9 => ["#FFF7EC", "#FEE8C8", "#FDD49E", "#FDBB84", "#FC8D59", "#EF6548", "#D7301F", "#B30000", "#7F0000"]
			],
			"Oranges" => Hash[
						3 => ["#FEE6CE", "#FDAE6B", "#E6550D" ],
						4 => ["#FEEDDE", "#FDBE85", "#FD8D3C", "#D94701" ],
						5 => ["#FEEDDE", "#FDBE85", "#FD8D3C", "#E6550D", "#A63603" ],
						6 => ["#FEEDDE", "#FDD0A2", "#FDAE6B", "#FD8D3C", "#E6550D", "#A63603" ],
						7 => ["#FEEDDE", "#FDD0A2", "#FDAE6B", "#FD8D3C", "#F16913", "#D94801", "#8C2D04" ],
						8 => ["#FFF5EB", "#FEE6CE", "#FDD0A2", "#FDAE6B", "#FD8D3C", "#F16913", "#D94801", "#8C2D04" ],
						9 => ["#FFF5EB", "#FEE6CE", "#FDD0A2", "#FDAE6B", "#FD8D3C", "#F16913", "#D94801", "#A63603", "#7F2704" ]
			],
			"Blues" => Hash[
						3 => ["#DEEBF7", "#9ECAE1", "#3182BD" ],
						4 => ["#EFF3FF", "#BDD7E7", "#6BAED6", "#2171B5" ],
						5 => ["#EFF3FF", "#BDD7E7", "#6BAED6", "#3182BD", "#08519C" ],
						6 => ["#EFF3FF", "#C6DBEF", "#9ECAE1", "#6BAED6", "#3182BD", "#08519C" ],
						7 => ["#EFF3FF", "#C6DBEF", "#9ECAE1", "#6BAED6", "#4292C6", "#2171B5", "#084594" ],
						8 => ["#F7FBFF", "#DEEBF7", "#C6DBEF", "#9ECAE1", "#6BAED6", "#4292C6", "#2171B5", "#084594" ],
						9 => ["#F7FBFF", "#DEEBF7", "#C6DBEF", "#9ECAE1", "#6BAED6", "#4292C6", "#2171B5", "#08519C", "#08306B" ]
			],
			"PuBu" => Hash[
						3 => ["#ECE7F2" , "#A6BDDB" , "#2B8CBE" ],
						4 => ["#F1EEF6" , "#BDC9E1" , "#74A9CF" , "#0570B0" ],
						5 => ["#F1EEF6" , "#BDC9E1" , "#74A9CF" , "#2B8CBE" , "#045A8D" ],
						6 => ["#F1EEF6" , "#D0D1E6" , "#A6BDDB" , "#74A9CF" , "#2B8CBE" , "#045A8D" ],
						7 => ["#F1EEF6" , "#D0D1E6" , "#A6BDDB" , "#74A9CF" , "#3690C0" , "#0570B0" , "#034E7B" ],
						8 => ["#FFF7FB" , "#ECE7F2" , "#D0D1E6" , "#A6BDDB" , "#74A9CF" , "#3690C0" , "#0570B0" , "#034E7B" ],
						9 => ["#FFF7FB" , "#ECE7F2" , "#D0D1E6" , "#A6BDDB" , "#74A9CF" , "#3690C0" , "#0570B0" , "#045A8D" , "#023858" ]
			]
		]
		return colors
	end

end
