module DataArchive
  require 'fileutils'
  require 'zip/zip'
	require 'utf8_converter'

	###########################################
	### get archives on file
	### - format = [ { "date" => [  {  "url", "file_size", "locale", "file_type"  }  ]  }  ]
	###########################################
  def self.get_archives
    files = []

    # get all archive directories in desc order
    dirs = Dir["#{archive_root}/*/"].map { |a| File.basename(a) }.sort{|a,b| b <=> a}
puts "dirs = #{dirs}"
    if dirs && !dirs.empty?
puts "dirs not empty"
      dirs.each do |dir|
puts "dir = #{dir}"
        archive_folder = Hash.new
        files << archive_folder

				# generate friendly date from the folder name
				folder = dir.gsub("_", "-").insert(13, ":").insert(16, ":")
				date = I18n.l(Time.parse(folder), :format => :long)
puts "date = #{date}"

        archive_folder[date] = Array.new
        Dir.glob("#{archive_root}/#{dir}/*.zip").sort.each do |file|
          archive_file = Hash.new
          archive_folder[date] << archive_file

          archive_file["url"] = "/#{url_path}/#{dir}/#{File.basename(file)}"
          archive_file["file_size"] = File.size(file)
          archive_file["locale"] = nil
          I18n.available_locales.each do |locale|
            if !File.basename(file).index("_#{locale.to_s.upcase}_").nil?
              archive_file["locale"] = locale.to_s.upcase
              break
            end
          end
          archive_file["file_type"] = nil
          archive_file["file_type"] = "CSV" if !File.basename(file).index("_CSV_").nil?
          archive_file["file_type"] = "XLS" if !File.basename(file).index("_XLS_").nil?
        end
      end
    end

    return files
  end


	###########################################
	### create download files
	###########################################
  def self.create_files
		start_time = Time.now
		timestamp = "#{I18n.l(start_time, :format => :file)}"
		logs = []
		files = {}
    # get all events
		events = Event.where("shape_id is not null").limit(5)
#		events = Event.where(:id => 1)

    if events && !events.empty?
			# create folder for zip files
			create_directory(archive_file_path(timestamp))

      # create a zip file for each locale
      I18n.available_locales.each do |locale|
        I18n.locale = locale
				# save the file names so they can easily be retrieved for zipping
				files[locale] = Hash.new
				files[locale]["CSV"] = Array.new
				files[locale]["XLS"] = Array.new

        events.each do |event|
					event_start_time = Time.now
          # get the data for this event
					data = Datum.get_all_data_for_event(event.id)

					if data && !data.empty?
			      # csv
			      csv_filename = spreadsheet_file_name(timestamp, event.name, "CSV")
						files[locale]["CSV"] << csv_filename
						# create the csv file
						File.open(archive_file_path(timestamp) + "/" + csv_filename, 'w') do |f|
							f.puts create_csv_formatted_string(data)
						end

			      # xls
			      xls_filename = spreadsheet_file_name(timestamp, event.name, "XLS")
						files[locale]["XLS"] << xls_filename
						# create the csv file
						File.open(archive_file_path(timestamp) + "/" + xls_filename, 'w') do |f|
							f.puts create_excel_formatted_string(data)
						end
					end
				logs << ">>>>>>>>>>> time to create files for event #{event.id} was #{Time.now - event_start_time} seconds"
        end
				# csv zip file
				zip_start = Time.now
				zip_file = archive_file_path(timestamp) + "/" + zip_file_name(timestamp, "CSV")
		    Zip::ZipFile.open(zip_file, Zip::ZipFile::CREATE) do |z|
					files[locale]["CSV"].each do |file|
						z.add(file, archive_file_path(timestamp) + "/" + file)
					end
				end
				# xls zip file
				zip_file = archive_file_path(timestamp) + "/" + zip_file_name(timestamp, "XLS")
		    Zip::ZipFile.open(zip_file, Zip::ZipFile::CREATE) do |z|
					files[locale]["XLS"].each do |file|
						z.add(file, archive_file_path(timestamp) + "/" + file)
					end
				end
				logs << ">>>>>>>>>>> time to zip files was #{Time.now - zip_start} seconds"
      end
    end
		# delete the csv/xls files that are no longer needed
		delete_files(archive_file_path(timestamp), files)

		logs << ">>>>>>>>>>> total time to create zip files was #{Time.now - start_time} seconds"

		logs.each {|x| Rails.logger.debug x}

  end

	###########################################
	### create spreadsheet formated string
	###########################################
	def self.create_csv_formatted_string(data)
		csv = ""
		if data && !data.empty?
			csv = CSV.generate(:col_sep => ",", :force_quotes => true) do |file|
				# add the rows
				data.each do |r|
					file << r
				end
			end
		end
		return csv
	end

	def self.create_excel_formatted_string(data)
		xls = []
		if data && !data.empty?
			xls << "<?xml version=\"1.0\"?>\n"
			xls << "<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\"\n"
			xls << "  xmlns:o=\"urn:schemas-microsoft-com:office:office\"\n"
			xls << "  xmlns:x=\"urn:schemas-microsoft-com:office:excel\"\n"
			xls << "  xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\"\n"
			xls << "  xmlns:html=\"http://www.w3.org/TR/REC-html40\">\n"
			xls << "  <Worksheet ss:Name=\"Sheet1\">\n"
			xls << "    <Table>\n"
			xls << "      <Row>\n"
			data.first.each do |header|
				xls << "        <Cell><Data ss:Type=\"String\">#{header}</Data></Cell>\n"
			end
			xls << "      </Row>\n"
			data.each_with_index do |row, i|
				if i > 0
					xls << "      <Row>\n"
					row.each do |cell|
						xls << "        <Cell><Data ss:Type=\"String\">#{cell}</Data></Cell>\n"
					end
					xls << "      </Row>\n"
				end
			end
			xls << "    </Table>\n"
			xls << "  </Worksheet>\n"
			xls << "</Workbook>"
		end
		return xls.join
	end

protected

	###########################################
	### delete files not needed
	### - assume collection is a hash of arrays
  ###   as used in the create_files method
	###########################################
	def self.delete_files(path, collection)
		if !collection.nil? && !collection.empty?
			collection.each_key do |key|
				collection[key].each_key do |key2|
					collection[key][key2].each do |file|
						File.delete(path + "/" + file)
					end
				end
			end
		end
	end

	###########################################
	### manage directory/file names
	###########################################
	def self.create_directory(path)
		if !path.nil? && path != "."
			FileUtils.mkpath(path)
		end
	end

  def self.url_path
  	"system/data_archives"
  end

  def self.archive_root
  	"#{Rails.root}/public/#{url_path}"
  end

  def self.archive_file_path(timestamp)
  	clean_filename("#{archive_root}/#{timestamp}")
  end

  def self.zip_file_name(timestamp, file_type)
  	clean_filename("#{I18n.t('app.common.app_name')}_#{I18n.t('app.common.data_archive')}_#{I18n.locale.to_s.upcase}_#{file_type}_#{timestamp}") + ".zip"
  end

  def self.spreadsheet_file_name(timestamp, event, file_type)
  	clean_filename("#{I18n.t('app.common.app_name')}_#{event}_#{I18n.locale.to_s.upcase}_#{file_type}_#{timestamp}") + ".#{file_type.downcase}"
  end

	def self.clean_filename(filename)
		Utf8Converter.convert_ka_to_en(filename.gsub(' ', '_').gsub(/[\\ \: \* \? \" \< \> \| \, \. ]/,''))
	end


end
