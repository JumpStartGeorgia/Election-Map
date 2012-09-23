class MenuLiveEventsController < ApplicationController
  before_filter :authenticate_user!
	cache_sweeper :menu_live_event_sweeper, :only => [:create, :update, :destroy]

  # GET /menu_live_events
  # GET /menu_live_events.json
  def index
    @live_events = MenuLiveEvent.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @live_events }
    end
  end

  # GET /menu_live_events/1
  # GET /menu_live_events/1.json
  def show
    @live_event = MenuLiveEvent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @live_event }
    end
  end

  # GET /menu_live_events/new
  # GET /menu_live_events/new.json
  def new
    @live_event = MenuLiveEvent.new
    gon.edit_menu_live_event = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @live_event }
    end
  end

  # GET /menu_live_events/1/edit
  def edit
    @live_event = MenuLiveEvent.find(params[:id])
    gon.edit_menu_live_event = true
		gon.menu_start_date = @live_event.menu_start_date.strftime('%m/%d/%Y %H:%M') if @live_event.menu_start_date
		gon.menu_end_date = @live_event.menu_end_date.strftime('%m/%d/%Y %H:%M') if @live_event.menu_end_date
		gon.data_available_at = @live_event.data_available_at.strftime('%m/%d/%Y %H:%M') if @live_event.data_available_at

  end

  # POST /menu_live_events
  # POST /menu_live_events.json
  def create
    @live_event = MenuLiveEvent.new(params[:menu_live_event])

    respond_to do |format|
      if @live_event.save
				msg = I18n.t('app.msgs.success_created', :obj => I18n.t('app.common.menu_live_event'))
				send_status_update(msg)
        format.html { redirect_to menu_live_events_path, notice: msg }
        format.json { render json: @live_event, status: :created, location: @live_event }
      else
        gon.edit_menu_live_event = true
    		gon.menu_start_date = @live_event.menu_start_date.strftime('%m/%d/%Y %H:%M') if @live_event.menu_start_date
    		gon.menu_end_date = @live_event.menu_end_date.strftime('%m/%d/%Y %H:%M') if @live_event.menu_end_date
		    gon.data_available_at = @live_event.data_available_at.strftime('%m/%d/%Y %H:%M') if @live_event.data_available_at
        format.html { render action: "new" }
        format.json { render json: @live_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /menu_live_events/1
  # PUT /menu_live_events/1.json
  def update
    @live_event = MenuLiveEvent.find(params[:id])

    respond_to do |format|
      if @live_event.update_attributes(params[:menu_live_event])
				msg = I18n.t('app.msgs.success_updated', :obj => I18n.t('app.common.menu_live_event'))
				send_status_update(msg)
        format.html { redirect_to menu_live_events_path, notice: msg }
        format.json { head :ok }
      else
        gon.edit_menu_live_event = true
    		gon.menu_start_date = @live_event.menu_start_date.strftime('%m/%d/%Y %H:%M') if @live_event.menu_start_date
    		gon.menu_end_date = @live_event.menu_end_date.strftime('%m/%d/%Y %H:%M') if @live_event.menu_end_date
		    gon.data_available_at = @live_event.data_available_at.strftime('%m/%d/%Y %H:%M') if @live_event.data_available_at
        format.html { render action: "edit" }
        format.json { render json: @live_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /menu_live_events/1
  # DELETE /menu_live_events/1.json
  def destroy
    @live_event = MenuLiveEvent.find(params[:id])
    @live_event.destroy

		msg = I18n.t('app.msgs.success_deleted', :obj => I18n.t('app.common.menu_live_event'))
		send_status_update(msg)
    respond_to do |format|
      format.html { redirect_to menu_live_events_url }
      format.json { head :ok }
    end
  end
end
