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
			flash[:info] =  t('app.msgs.does_not_exist')
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
			flash[:info] =  t('app.msgs.does_not_exist')
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
			flash[:info] =  t('app.msgs.does_not_exist')
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
    # get indicator info
    data = JSON.parse(get_core_indicator_events)
    @indicator = data.select{|x| x["id"].to_s == params[:id]}.first

    if @indicator.present?
      # if event type id in url, use it to set the active view
      @active_index = 0
      if params[:event_type_id].present?
        index = @indicator["event_types"].index{|x| x["id"].to_s == params[:event_type_id]}
        @active_index = index if index.present?
      end

      @districts = UniqueShapeName.get_districts

      gon.indicator_profile = @indicator
      gon.summary_chart_title = I18n.t('charts.indicator_profile.summary.title')
      gon.summary_chart_rest = I18n.t('charts.indicator_profile.summary.rest')
      gon.chart_no_data = I18n.t('charts.no_data')

      gon.placeholder_core_indicator = I18n.t('app.common.placeholder_core_indicator')
      gon.placeholder_event_type = I18n.t('app.common.placeholder_event_type')
      gon.placeholder_shape_type_id = I18n.t('app.common.placeholder_shape_type_id')
      gon.placeholder_common_id = I18n.t('app.common.placeholder_common_id')
      gon.placeholder_common_name = I18n.t('app.common.placeholder_common_name')
      if @indicator["type_id"] == 2
        gon.json_indicator_event_type_data_url = json_indicator_event_type_summary_data_path(:core_indicator_id => gon.placeholder_core_indicator, :event_type_id => gon.placeholder_event_type)
        gon.json_indicator_event_type_data_url_district_filter = json_indicator_event_type_summary_data_path(:core_indicator_id => gon.placeholder_core_indicator, :event_type_id => gon.placeholder_event_type, :shape_type_id => gon.placeholder_shape_type_id, :common_id => gon.placeholder_common_id, :common_name => gon.placeholder_common_name)
      else
        gon.json_indicator_event_type_data_url = json_indicator_event_type_data_path(:core_indicator_id => gon.placeholder_core_indicator, :event_type_id => gon.placeholder_event_type)
        gon.json_indicator_event_type_data_url_district_filter = json_indicator_event_type_data_path(:core_indicator_id => gon.placeholder_core_indicator, :event_type_id => gon.placeholder_event_type, :shape_type_id => gon.placeholder_shape_type_id, :common_id => gon.placeholder_common_id, :common_name => gon.placeholder_common_name)
      end
      
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @data }
      end
    else
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to indicator_profiles_path
    end
  
  end

  #####################
  ### district profiles
  #####################
  def districts
    # get all districts and their event info
    @data = JSON.parse(get_district_events_table)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @data }
    end
  end

  def district
    # get district info
    data = JSON.parse(get_district_events)
    @district = data.select{|x| x["common_id"] == params[:id]}.first

    if @district.present?
      # if event type id in url, use it to set the active view
      @active_index = 0
      if params[:event_type_id].present?
        index = @district["event_types"].index{|x| x["id"].to_s == params[:event_type_id]}
        @active_index = index if index.present?
      end

      gon.district_profile = @district
      gon.has_summary = @district["event_types"][@active_index]["has_summary"]
      gon.default_indicator_id = @district["event_types"][@active_index]["default_indicator_id"]
      gon.summary_chart_title = I18n.t('charts.indicator_profile.summary.title')
      gon.summary_chart_rest = I18n.t('charts.indicator_profile.summary.rest')
      gon.chart_no_data = I18n.t('charts.no_data')

      gon.placeholder_event_type = I18n.t('app.common.placeholder_event_type')
      gon.placeholder_indicator = I18n.t('app.common.placeholder_indicator')
      gon.placeholder_core_indicator = I18n.t('app.common.placeholder_core_indicator')

      gon.json_district_event_type_summary_data_url = json_district_event_type_summary_data_path(:common_id => params[:id], 
            :event_type_id => gon.placeholder_event_type, 
            :indicator_type_id => gon.placeholder_indicator)
      gon.json_district_event_type_data_url = json_district_event_type_data_path(:common_id => params[:id], 
            :event_type_id => gon.placeholder_event_type, 
            :core_indicator_id => gon.placeholder_core_indicator)


      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @data }
      end
    else
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to indicator_profiles_path
    end
  
  end
end
