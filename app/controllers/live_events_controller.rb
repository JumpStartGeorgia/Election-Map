class LiveEventsController < ApplicationController
  before_filter :authenticate_user!

  def load_data
    @live_events = Event.live_events("desc")
    @live_data_set = LiveDataSet.new
    gon.load_data_live_event = true
    
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
  				    redirect_to load_data_live_events_path #GET
  		      else
  		        # errors
  						flash[:error] = I18n.t('app.msgs.upload.error', :file_name => params[:file].original_filename, :msg => msg)
  				    redirect_to load_data_live_events_path #GET
  		      end
  				else
  					flash[:error] = I18n.t('app.msgs.missing_parameters')
  		      redirect_to load_data_live_events_path #GET
  				end
				else
					flash[:error] = I18n.t('app.msgs.upload.wrong_format', :file_name => params[:file].original_filename)
		      redirect_to load_data_live_events_path #GET
				end
			else
				flash[:error] = I18n.t('app.msgs.upload.no_file')
	      redirect_to load_data_live_events_path #GET
			end
    end
  end

  # GET /live_events
  # GET /live_events.json
  def index
    @live_events = LiveEvent.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @live_events }
    end
  end

  # GET /live_events/1
  # GET /live_events/1.json
  def show
    @live_event = LiveEvent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @live_event }
    end
  end

  # GET /live_events/new
  # GET /live_events/new.json
  def new
    @live_event = LiveEvent.new
    gon.edit_live_event = true
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @live_event }
    end
  end

  # GET /live_events/1/edit
  def edit
    @live_event = LiveEvent.find(params[:id])
    gon.edit_live_event = true
		gon.menu_start_date = @live_event.menu_start_date.strftime('%m/%d/%Y %H:%M') if @live_event.menu_start_date
		gon.menu_end_date = @live_event.menu_end_date.strftime('%m/%d/%Y %H:%M') if @live_event.menu_end_date
    
  end

  # POST /live_events
  # POST /live_events.json
  def create
    @live_event = LiveEvent.new(params[:live_event])

    respond_to do |format|
      if @live_event.save
        format.html { redirect_to @live_event, notice: 'Live event was successfully created.' }
        format.json { render json: @live_event, status: :created, location: @live_event }
      else
        gon.edit_live_event = true
    		gon.menu_start_date = @live_event.menu_start_date.strftime('%m/%d/%Y %H:%M') if @live_event.menu_start_date
    		gon.menu_end_date = @live_event.menu_end_date.strftime('%m/%d/%Y %H:%M') if @live_event.menu_end_date
        format.html { render action: "new" }
        format.json { render json: @live_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /live_events/1
  # PUT /live_events/1.json
  def update
    @live_event = LiveEvent.find(params[:id])

    respond_to do |format|
      if @live_event.update_attributes(params[:live_event])
        format.html { redirect_to @live_event, notice: 'Live event was successfully updated.' }
        format.json { head :ok }
      else
        gon.edit_live_event = true
    		gon.menu_start_date = @live_event.menu_start_date.strftime('%m/%d/%Y %H:%M') if @live_event.menu_start_date
    		gon.menu_end_date = @live_event.menu_end_date.strftime('%m/%d/%Y %H:%M') if @live_event.menu_end_date
        format.html { render action: "edit" }
        format.json { render json: @live_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /live_events/1
  # DELETE /live_events/1.json
  def destroy
    @live_event = LiveEvent.find(params[:id])
    @live_event.destroy

    respond_to do |format|
      format.html { redirect_to live_events_url }
      format.json { head :ok }
    end
  end
end
