class LiveDataSetsController < ApplicationController
  before_filter :authenticate_user!

  def load_data
    @live_events = Event.live_events("desc")
    @live_data_set = LiveDataSet.new
    gon.load_data_live_dataset = true

		if request.post?
			if params[:file].present?
				if params[:file].content_type == "text/csv" || params[:file].content_type == "text/plain"
          if params[:event_id] && !params[:event_id].empty? &&
              params[:precincts_completed] && !params[:precincts_completed].empty? &&
              params[:precincts_total] && !params[:precincts_total].empty?  &&
              params[:timestamp] && !params[:timestamp].empty?

  			    start = Time.now

				    msg = LiveDatum.build_from_csv(params[:event_id],
                    params[:precincts_completed],
                    params[:precincts_total],
                    params[:timestamp],
      				      params[:file])

  		      if msg.nil? || msg.empty?
  		        # no errors, success!
  						msg = I18n.t('app.msgs.upload.success_live_event', :file_name => params[:file].original_filename)
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

  # GET /live_data_sets
  # GET /live_data_sets.json
  def index
    @live_data_sets = LiveDataSet.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @live_data_sets }
    end
  end

  # GET /live_data_sets/1
  # GET /live_data_sets/1.json
  def show
    @live_data_set = LiveDataSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @live_data_set }
    end
  end
=begin can only create though uploading csv file (load_data event)
  # GET /live_data_sets/new
  # GET /live_data_sets/new.json
  def new
    @live_data_set = LiveDataSet.new
    gon.edit_live_dataset = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @live_data_set }
    end
  end
=end

  # GET /live_data_sets/1/edit
  def edit
    @live_data_set = LiveDataSet.find(params[:id])
    gon.edit_live_dataset = true
		gon.timestamp = @live_data_set.timestamp.strftime('%m/%d/%Y %H:%M') if @live_data_set.timestamp
  end

=begin can only create though uploading csv file (load_data event)
  # POST /live_data_sets
  # POST /live_data_sets.json
  def create
    @live_data_set = LiveDataSet.new(params[:live_data_set])

    respond_to do |format|
      if @live_data_set.save
				msg = I18n.t('app.msgs.success_created', :obj => I18n.t('app.common.live_data_set'))
				send_status_update(msg)
        format.html { redirect_to live_data_sets_path, notice: msg }
        format.json { render json: @live_data_set, status: :created, location: @live_data_set }
      else
        gon.edit_live_dataset = true
    		gon.timestamp = @live_data_set.timestamp.strftime('%m/%d/%Y %H:%M') if @live_data_set.timestamp
        format.html { render action: "new" }
        format.json { render json: @live_data_set.errors, status: :unprocessable_entity }
      end
    end
  end
=end
  # PUT /live_data_sets/1
  # PUT /live_data_sets/1.json
  def update
    @live_data_set = LiveDataSet.find(params[:id])

    respond_to do |format|
      if @live_data_set.update_attributes(params[:live_data_set])
				msg = I18n.t('app.msgs.success_updated', :obj => I18n.t('app.common.live_data_set'))
				send_status_update(msg)
        format.html { redirect_to live_data_sets_path, notice: msg }
        format.json { head :ok }
      else
        gon.edit_live_dataset = true
    		gon.timestamp = @live_data_set.timestamp.strftime('%m/%d/%Y %H:%M') if @live_data_set.timestamp
        format.html { render action: "edit" }
        format.json { render json: @live_data_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /live_data_sets/1
  # DELETE /live_data_sets/1.json
  def destroy
    @live_data_set = LiveDataSet.find(params[:id])
    @live_data_set.destroy

		msg = I18n.t('app.msgs.success_deleted', :obj => I18n.t('app.common.live_dataset'))
		send_status_update(msg)
    respond_to do |format|
      format.html { redirect_to live_data_sets_url }
      format.json { head :ok }
    end
  end
end
