module PerformanceTest
require 'ruby-prof'

	def self.test
		RubyProf.start

	  Event.all

		results = RubyProf.stop

	 File.open "#{Rails.root}/tmp/profile-graph.html", 'w' do |file|
		 RubyProf::GraphHtmlPrinter.new(results).print(file)
	 end
	 
	 File.open "#{Rails.root}/tmp/profile-flat.txt", 'w' do |file|
		 RubyProf::FlatPrinter.new(results).print(file)
	 end
	 
	 File.open "#{Rails.root}/tmp/profile-tree.prof", 'w' do |file|
		 RubyProf::CallTreePrinter.new(results).print(file)
	 end

	end

  def self.load_json(event_id, indicator_id)
		event = Event.find(event_id)

		RubyProf.start

	  app.get "/en/json/children_shapes/#{event.shape_id}/parent_clickable/false/indicator/#{indicator_id}"

		results = RubyProf.stop

		File.open "#{Rails.root}/tmp/load_json_#{event_id}_#{indicator_id}_profile-callstack.html", 'w' do |file|
		 RubyProf::CallStackPrinter.new(results).print(file)
		end

		File.open "#{Rails.root}/tmp/load_json_#{event_id}_#{indicator_id}_profile-flat.txt", 'w' do |file|
		 RubyProf::FlatPrinter.new(results).print(file)
		end

		File.open "#{Rails.root}/tmp/load_json_#{event_id}_#{indicator_id}_profile-tree.prof", 'w' do |file|
		 RubyProf::CallTreePrinter.new(results).print(file)
		end

	end

  def self.load_json_district_view(event_id, shape_type_id, indicator_id)
		event = Event.find(event_id)

		RubyProf.start

	  app.get "/en/json/custom_children_shapes/#{event.shape_id}/indicator/#{indicator_id}/shape_type/#{shape_type_id}"

		results = RubyProf.stop

		File.open "#{Rails.root}/tmp/load_json_district_view_#{event_id}_#{shape_type_id}_#{indicator_id}_profile-graph.html", 'w' do |file|
		 RubyProf::GraphHtmlPrinter.new(results).print(file)
		end

		File.open "#{Rails.root}/tmp/load_json_district_view_#{event_id}_#{shape_type_id}_#{indicator_id}_profile-flat.txt", 'w' do |file|
		 RubyProf::FlatPrinter.new(results).print(file)
		end

		File.open "#{Rails.root}/tmp/load_json_district_view_#{event_id}_#{shape_type_id}_#{indicator_id}_profile-tree.prof", 'w' do |file|
		 RubyProf::CallTreePrinter.new(results).print(file)
		end

	end

	def self.load_summary_json_district_view(event_id, shape_type_id, indicator_type_id)
		event = Event.find(event_id)

		RubyProf.start

	  app.get "/en/json/summary_custom_children_shapes/#{event.shape_id}/event/#{event.id}/indicator_type/#{indicator_type_id}/shape_type/#{shape_type_id}"

results = RubyProf.stop

		File.open "#{Rails.root}/tmp/load_summary_json_district_view_#{event_id}_#{shape_type_id}_#{indicator_type_id}_profile-graph.html", 'w' do |file|
		 RubyProf::GraphHtmlPrinter.new(results).print(file)
		end

		File.open "#{Rails.root}/tmp/load_summary_json_district_view_#{event_id}_#{shape_type_id}_#{indicator_type_id}_profile-flat.txt", 'w' do |file|
		 RubyProf::FlatPrinter.new(results).print(file)
		end

		File.open "#{Rails.root}/tmp/load_summary_json_district_view_#{event_id}_#{shape_type_id}_#{indicator_type_id}_profile-tree.prof", 'w' do |file|
		 RubyProf::CallTreePrinter.new(results).print(file)
		end
	end
end
