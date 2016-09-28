module DataArchive
  require 'fileutils'
  # require 'zip'
	require 'utf8_converter'

  ###########################################
  ### get archive on file
  ### - event_id: id of event
  ### - locale: locale to get data in
  ### - file_type: type of file (csv or xls)
  ###########################################
  def self.get_archive(event_id, locale, file_type)
    file_path = "#{archive_file_path(event_id)}/#{locale}.#{file_type.downcase}"
    # if file does not exist, create it
    create_file(event_id, locale) if !File.exists?(file_path)

    # return file path
    return file_path
  end

  ######################
  ## generate the file name for the archive file that is to be downloaded to user
  def self.create_archive_filename(event_name, file_locale, file_type)
    spreadsheet_file_name(event_name, file_locale, file_type)
  end

  ######################
  ## delete the existing files for an event
  def self.delete_archive(event_id)
    FileUtils.rm_rf(archive_file_path(event_id))
  end



  ###########################################
  ### create download files
  ###########################################

  ### create data archive CSV and XLS file for the provided event and locale
  def self.create_file(event_id, locale)
    original_locale = I18n.locale
    I18n.locale = locale.to_sym

    events = Event.where(:id => event_id)

    if events.present?
      event = events.first

      # create folder for to store files
      path = archive_file_path(event_id)
      create_directory(path)

      # get the most recent official data set
      most_recent_dataset = DataSet.current_dataset(event.id, 'official')
      if most_recent_dataset.present?
        # get the data for this event
        data = Datum.get_all_data_for_event(event.id, most_recent_dataset.first.id)

        if data.present?
          # csv
          csv_filename = "#{locale}.csv"
          # create the csv file
          File.open(path + "/" + csv_filename, 'w') do |f|
            f.puts create_csv_formatted_string(data)
          end

          # xls
          xls_filename = "#{locale}.xls"
          # create the xls file
          File.open(path + "/" + xls_filename, 'w') do |f|
            f.puts create_excel_formatted_string(data)
          end

        end
      end
    end

    # reset the locale
    I18n.locale = original_locale

  end

=begin old way
	###########################################
	### get archives on file
	### - format = [ { "folder" => "folder_name" , "date" => "date", "files" => [  {  "url", "file_size", "locale", "file_type"  }  ]  }  ]
	###########################################
  def self.get_archives
#		Rails.cache.fetch(cache_key) {
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
			    archive_folder["folder"] = dir

					# generate friendly date from the folder name
					folder = dir.gsub("_", "-").insert(13, ":").insert(16, ":")
					date = I18n.l(Time.parse(folder), :format => :long)
		      archive_folder["date"] = date
	puts "date = #{date}"

			    archive_folder["files"] = Array.new
			    Dir.glob("#{archive_root}/#{dir}/*.zip").sort.each do |file|
			      archive_file = Hash.new
			      archive_folder["files"] << archive_file

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
    	files
#		}
  end


  ### create complete set of data archives
  def self.create_files(event_id = nil)
		start_time = Time.now
		timestamp = "#{I18n.l(start_time, :format => :file)}"
		logs = []
		files = {}
		original_locale = I18n.locale

    # get all events
    events = nil
    if event_id.present?
      events = Event.where(:id => event_id)
    else
  		events = Event.where("shape_id is not null")
    end

    if events.present?
			# create folder for zip files
			create_directory(archive_file_time_path(timestamp))

      # create a zip file for each locale
      I18n.available_locales.each do |locale|
        I18n.locale = locale
				# save the file names so they can easily be retrieved for zipping
				files[locale] = Hash.new
				files[locale]["CSV"] = Array.new
				files[locale]["XLS"] = Array.new

        events.each do |event|
					event_start_time = Time.now
					# get the most recent official data set
		      most_recent_dataset = DataSet.current_dataset(event.id, 'official')
					if most_recent_dataset && !most_recent_dataset.empty?
		        # get the data for this event
						data = Datum.get_all_data_for_event(event.id, most_recent_dataset.first.id)

						if data.present?
					    # csv
					    csv_filename = spreadsheet_file_time_name(timestamp, event.name, "CSV")
							files[locale]["CSV"] << csv_filename
							# create the csv file
							File.open(archive_file_time_path(timestamp) + "/" + csv_filename, 'w') do |f|
								f.puts create_csv_formatted_string(data)
							end

					    # xls
					    xls_filename = spreadsheet_file_time_name(timestamp, event.name, "XLS")
							files[locale]["XLS"] << xls_filename
							# create the csv file
							File.open(archive_file_time_path(timestamp) + "/" + xls_filename, 'w') do |f|
								f.puts create_excel_formatted_string(data)
							end
						end
						logs << ">>>>>>>>>>> time to create files for event #{event.id} was #{Time.now - event_start_time} seconds"
					end
        end
				# csv zip file
				zip_start = Time.now
				zip_file = archive_file_time_path(timestamp) + "/" + zip_file_name(timestamp, "CSV")
		    Zip::ZipFile.open(zip_file, Zip::ZipFile::CREATE) do |z|
					files[locale]["CSV"].each do |file|
						z.add(file, archive_file_time_path(timestamp) + "/" + file)
					end
				end
				# set read permissions on the file
				File.chmod(0644, zip_file)

				# xls zip file
				zip_file = archive_file_time_path(timestamp) + "/" + zip_file_name(timestamp, "XLS")
		    Zip::ZipFile.open(zip_file, Zip::ZipFile::CREATE) do |z|
					files[locale]["XLS"].each do |file|
						z.add(file, archive_file_time_path(timestamp) + "/" + file)
					end
				end
				# set read permissions on the file
				File.chmod(0644, zip_file)

				logs << ">>>>>>>>>>> time to zip files was #{Time.now - zip_start} seconds"
      end
    end
		# delete the csv/xls files that are no longer needed
		delete_files(archive_file_time_path(timestamp), files)

		logs << ">>>>>>>>>>> total time to create zip files was #{Time.now - start_time} seconds"

		# reset the locale
		I18n.locale = original_locale

		logs.each {|x| Rails.logger.debug x}

  end

=end

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

	def self.cache_key
		return "data_archives_#{I18n.locale}"
	end

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

  def self.archive_file_path(event_id)
    clean_filename("#{archive_root}/#{event_id}")
  end

  def self.archive_file_time_path(timestamp)
  	clean_filename("#{archive_root}/#{timestamp}")
  end

  def self.zip_file_name(timestamp, file_type)
  	clean_filename("#{I18n.t('app.common.app_name')}_#{I18n.t('app.common.data_archive')}_#{I18n.locale.to_s.upcase}_#{file_type}_#{timestamp}") + ".zip"
  end

  def self.spreadsheet_file_name(event, file_locale, file_type)
    clean_filename("#{I18n.t('app.common.app_name', :locale => file_locale.to_sym)}_#{event}_#{file_locale.upcase}_#{file_type.upcase}") + ".#{file_type.downcase}"
  end

  def self.spreadsheet_file_time_name(timestamp, event, file_type)
  	clean_filename("#{I18n.t('app.common.app_name')}_#{event}_#{I18n.locale.to_s.upcase}_#{file_type}_#{timestamp}") + ".#{file_type.downcase}"
  end

	def self.clean_filename(filename)
		Utf8Converter.convert_ka_to_en(filename.gsub(' ', '_').gsub(/[\\ \: \* \? \" \< \> \| \, \. ]/,''))
	end


end
