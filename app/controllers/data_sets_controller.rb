class DataSetsController < ApplicationController
  before_filter :authenticate_user!

  def load_data
		@events = Event.get_all_events
    @live_events_menu = Event.live_events_menu("desc")
    @data_set = DataSet.new
    gon.load_data_dataset = true

		if request.post?
			if params[:file].present?
				if params[:file].content_type == "text/csv" || params[:file].content_type == "text/plain"
          if (params[:data_type] == Datum::DATA_TYPE[:official] &&
							params[:event_id_official] && !params[:event_id_official].empty? &&
              params[:timestamp] && !params[:timestamp].empty?
						) || (params[:data_type] == Datum::DATA_TYPE[:live] &&
							params[:event_id_live] && !params[:event_id_live].empty? &&
              params[:precincts_completed] && !params[:precincts_completed].empty? &&
              params[:precincts_total] && !params[:precincts_total].empty?  &&
              params[:timestamp] && !params[:timestamp].empty?
						)

  			    start = Time.now
						msg = nil
						if params[:data_type] == Datum::DATA_TYPE[:official]
						  msg = LiveDatum.build_from_csv(params[:event_id_official],
											params[:data_type],
		                  nil,
		                  nil,
		                  params[:timestamp],
		    				      params[:file])
						elsif params[:data_type] == Datum::DATA_TYPE[:live]
						  msg = LiveDatum.build_from_csv(params[:event_id_live],
											params[:data_type],
		                  params[:precincts_completed],
		                  params[:precincts_total],
		                  params[:timestamp],
		    				      params[:file])
						end

  		      if msg.nil? || msg.empty?
  		        # no errors, success!
  						msg = I18n.t('app.msgs.upload.success', :file_name => params[:file].original_filename)
  						flash[:success] = msg
  						send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg), Time.now-start)
  		      else
  		        # errors
  						flash[:error] = I18n.t('app.msgs.upload.error', :file_name => params[:file].original_filename, :msg => msg)
  		      end
  				else
  					flash[:error] = I18n.t('app.msgs.missing_parameters')
  				end
				else
					flash[:error] = I18n.t('app.msgs.upload.wrong_format', :file_name => params[:file].original_filename)
				end
			else
				flash[:error] = I18n.t('app.msgs.upload.no_file')
			end
    end
  end

  # GET /data_sets
  # GET /data_sets.json
  def index
    @data_sets = DataSet.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @data_sets }
    end
  end

  # GET /data_sets/1
  # GET /data_sets/1.json
  def show
    @data_set = DataSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @data_set }
    end
  end
=begin can only create though uploading csv file (load_data event)
  # GET /data_sets/new
  # GET /data_sets/new.json
  def new
    @data_set = DataSet.new
    gon.edit_dataset = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @data_set }
    end
  end
=end

  # GET /data_sets/1/edit
  def edit
    @data_set = DataSet.find(params[:id])
    gon.edit_dataset = true
		gon.timestamp = @data_set.timestamp.strftime('%m/%d/%Y %H:%M') if @data_set.timestamp
  end

=begin can only create though uploading csv file (load_data event)
  # POST /data_sets
  # POST /data_sets.json
  def create
    @data_set = DataSet.new(params[:data_set])

    respond_to do |format|
      if @data_set.save
				msg = I18n.t('app.msgs.success_created', :obj => I18n.t('app.common.data_set'))
				send_status_update(msg)
        format.html { redirect_to data_sets_path, notice: msg }
        format.json { render json: @data_set, status: :created, location: @data_set }
      else
        gon.edit_dataset = true
    		gon.timestamp = @data_set.timestamp.strftime('%m/%d/%Y %H:%M') if @data_set.timestamp
        format.html { render action: "new" }
        format.json { render json: @data_set.errors, status: :unprocessable_entity }
      end
    end
  end
=end
  # PUT /data_sets/1
  # PUT /data_sets/1.json
  def update
    @data_set = DataSet.find(params[:id])

    respond_to do |format|
      if @data_set.update_attributes(params[:data_set])
				msg = I18n.t('app.msgs.success_updated', :obj => I18n.t('app.common.data_set'))
				send_status_update(msg)
        format.html { redirect_to data_sets_path, notice: msg }
        format.json { head :ok }
      else
        gon.edit_dataset = true
    		gon.timestamp = @data_set.timestamp.strftime('%m/%d/%Y %H:%M') if @data_set.timestamp
        format.html { render action: "edit" }
        format.json { render json: @data_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data_sets/1
  # DELETE /data_sets/1.json
  def destroy
    @data_set = DataSet.find(params[:id])
    @data_set.destroy

		msg = I18n.t('app.msgs.success_deleted', :obj => I18n.t('app.common.data_set'))
		send_status_update(msg)
    respond_to do |format|
      format.html { redirect_to data_sets_url }
      format.json { head :ok }
    end
  end
end
