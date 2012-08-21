# encoding: utf-8
class DataArchivesController < ApplicationController
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
		if @archive && !@archive.empty?
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

	protected

	# get all archives if user logged in,
  # otherwise, only those that have news posts
	def available_archives
		available = []
		archives = DataArchive.get_archives
		news = News.data_archives

		# now determine which archives have a news story
		if news && !news.empty?
			# news items with archives, determine which ones have news story
			archives.each do |archive|
				index = news.index{|n| n.data_archive_folder == archive["folder"]}
				if index || user_signed_in?
					archive["news"] =  news[index].description if index
					available << archive
				end
			end
		elsif user_signed_in?
			# there are no news items with archives
			available = archive
		end
		return available
	end
end
