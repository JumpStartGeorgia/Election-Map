# encoding: utf-8
class OtherController < ApplicationController
  def about
    @page = Page.with_translations(I18n.locale).find_by_name("about")

		if @page.present?
		  if params[:layout].present?
				render :action => "page", :layout => params[:layout]
		  else
		    respond_to do |format|
		      format.html { render action: "page" }
		      format.json { render json: @page }
		    end
			end
		else
			# no page was found, send back to home
			redirect_to root_path
		end
  end

  def data_source
    @page = Page.with_translations(I18n.locale).find_by_name("data_source")

		if @page.present?
		  if params[:layout].present?
				render :action => "page", :layout => params[:layout]
		  else
		    respond_to do |format|
		      format.html { render action: "page" }
		      format.json { render json: @page }
		    end
			end
		else
			# no page was found, send back to home
			redirect_to root_path
		end
  end

  def export_help
    @page = Page.with_translations(I18n.locale).find_by_name("export_help")

		if @page.present?
		  if params[:layout].present?
				render :action => "page", :layout => params[:layout]
		  else
		    respond_to do |format|
		      format.html { render action: "page" }
		      format.json { render json: @page }
		    end
			end
		else
			# no page was found, send back to home
			redirect_to root_path
		end
  end

  def news
    @news = News.recent.with_translations(I18n.locale).paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @news }
    end
  end

  def data_archives
		@archives = available_archives.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @news }
    end
  end

  def data_archive
		@archive = available_archives.select{|x| x["folder"] == params[:data_archive_folder]}
		if @archive.present?
			@archive = @archive.first
		else
			@archive = nil
		end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @news }
    end
  end


  #####################
  ### indicator profiles
  #####################
  def indicators
    # get all indicators and their event info
    @data = JSON.parse(get_core_indicator_events_table)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @data }
    end
  end

  def indicator

  end


end
