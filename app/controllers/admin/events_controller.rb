class Admin::EventsController < ApplicationController
  before_filter :authenticate_user!
	cache_sweeper :event_sweeper, :only => [:create, :update, :destroy]

  # GET /events
  # GET /events.json
  def index
    @events = Event.get_all_events_by_date.includes(:event_type)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
			@event.event_translations.build(:locale => locale)
		end

		# turn the datetime picker js on
		# have to format dates this way so js datetime picker read them properly
		gon.edit_event = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
		# turn the datetime picker js on
		# have to format dates this way so js datetime picker read them properly
		gon.edit_event = true
		gon.event_date = @event.event_date.strftime('%m/%d/%Y %H:%M') if !@event.event_date.nil?
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])

    respond_to do |format|
      if @event.save
				msg = I18n.t('app.msgs.success_created', :obj => I18n.t('app.common.event'))
				send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg))
        format.html { redirect_to admin_event_path(@event), notice: msg }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
				msg = I18n.t('app.msgs.success_updated', :obj => I18n.t('app.common.event'))
				send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg))
        format.html { redirect_to admin_event_path(@event), notice: msg }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

		msg = I18n.t('app.msgs.success_deleted', :obj => I18n.t('app.common.event'))
		send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg))
    respond_to do |format|
      format.html { redirect_to admin_events_url }
      format.json { head :ok }
    end
  end
end
