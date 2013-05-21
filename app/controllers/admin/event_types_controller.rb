class Admin::EventTypesController < ApplicationController
  before_filter :authenticate_user!
	cache_sweeper :event_type_sweeper, :only => [:create, :update, :destroy]

  # GET /event_types
  # GET /event_types.json
  def index
    @event_types = EventType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @event_types }
    end
  end

  # GET /event_types/1
  # GET /event_types/1.json
  def show
    @event_type = EventType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event_type }
    end
  end

  # GET /event_types/new
  # GET /event_types/new.json
  def new
    @event_type = EventType.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
			@event_type.event_type_translations.build(:locale => locale)
		end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event_type }
    end
  end

  # GET /event_types/1/edit
  def edit
    @event_type = EventType.find(params[:id])
  end

  # POST /event_types
  # POST /event_types.json
  def create
    @event_type = EventType.new(params[:event_type])

    respond_to do |format|
      if @event_type.save
				msg = I18n.t('app.msgs.success_created', :obj => I18n.t('app.common.event_type'))
				send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg))
        format.html { redirect_to admin_event_type_path(@event_type), notice: msg }
        format.json { render json: @event_type, status: :created, location: @event_type }
      else
        format.html { render action: "new" }
        format.json { render json: @event_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /event_types/1
  # PUT /event_types/1.json
  def update
    @event_type = EventType.find(params[:id])

    respond_to do |format|
      if @event_type.update_attributes(params[:event_type])
				msg = I18n.t('app.msgs.success_updated', :obj => I18n.t('app.common.event_type'))
				send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg))
        format.html { redirect_to admin_event_type_path(@event_type), notice: msg }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @event_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_types/1
  # DELETE /event_types/1.json
  def destroy
    @event_type = EventType.find(params[:id])
    @event_type.destroy

		msg = I18n.t('app.msgs.success_deleted', :obj => I18n.t('app.common.event_type'))
		send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg))
    respond_to do |format|
      format.html { redirect_to admin_event_types_url }
      format.json { head :ok }
    end
  end
end
