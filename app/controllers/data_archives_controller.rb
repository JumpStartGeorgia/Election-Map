# encoding: utf-8
class DataArchivesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  require 'data_archive'

	# /data_archives
	def index
		# get a list of all directories
	end

	# /data_archives/:id
	# - :id = name of folder
	def show

	end

	# /data_archives/new
	def new
		if request.post?
			DataArchive.create_files
			flash[:notice] = I18n.t('data_archives.new.created')
		end
	end


end
