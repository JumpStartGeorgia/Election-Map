module DataDownload
  require 'fileutils'
  require 'zip/zip'

	###########################################
	### manage directores
	###########################################
	def self.create_directory(subpath=nil)
		if !subpath.nil? && subpath != "."
			FileUtils.mkpath(download_file_path + "/" + subpath)
		else
  		FileUtils.mkpath(download_file_path)
		end
	end

	###########################################
	### data download files
	###########################################
  # return an array to all of the available data download files
  def self.data_download_files
    files = []
    
    return files
  end


	###########################################
	### create download files
	###########################################
  def self.create_files
    # get all events
		events = Event.where("shape_id is not null")

    if events && !events.empty?
      # create a zip file for each locale
      I18n.avilable_locale.each do |locale|
        I18n.locale = locale
        events.each do |event|
          # get the data for this event
        end
      end
    end
  end
protected 

  def self.download_file_path
  	"#{Rails.root}/public/data_downloads"
  end
end