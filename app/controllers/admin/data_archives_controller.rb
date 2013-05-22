# encoding: utf-8
class Admin::DataArchivesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  require 'data_archive'
  require 'will_paginate/array'

	# /data_archives
	def index
		# get a list of all directories
		@archives = available_archives.paginate(:page => params[:page])
	end

	# /data_archives/:data_archive_folder
	def show
		@archive = available_archives.select{|x| x["folder"] == params[:data_archive_folder]}
		if @archive.present?
			@archive = @archive.first
		else
			@archive = nil
		end
	end

	# /data_archives/new
	def new
		if request.post?
			start = Time.now
			DataArchive.create_files
			flash[:notice] = I18n.t('data_archives.new.created')
			send_status_update(I18n.t('data_archives.new.created'), Time.now-start)
		end
	end

end
