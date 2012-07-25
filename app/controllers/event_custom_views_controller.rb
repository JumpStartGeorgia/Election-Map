class EventCustomViewsController < ApplicationController
  before_filter :authenticate_user!
	cache_sweeper :event_custom_view_sweeper, :only => [:create, :update, :destroy]

  def index
		@event_custom_views = EventCustomView
			.includes({:event => :event_translations}, :shape_type, :descendant_shape_type)
			.order("events.event_type_id asc, events.event_date desc, event_translations.name asc")
  end

  def new
		gon.load_js_event_custom_view_form = true
    @event_custom_view = EventCustomView.new
  end

  def edit
    @event_custom_view = EventCustomView.find(params[:id])
		gon.load_js_event_custom_view_form = true
		gon.event_id = @event_custom_view.event_id
		gon.shape_type_id = @event_custom_view.shape_type_id
		gon.descendant_shape_type_id = @event_custom_view.descendant_shape_type_id
  end

  # POST /events
  # POST /events.json
  def create
    @event_custom_view = EventCustomView.new(params[:event_custom_view])

    respond_to do |format|
      if @event_custom_view.save
        format.html { redirect_to event_custom_views_path, notice: 'Event Custom View was successfully created.' }
        format.json { render json: @event_custom_view, status: :created, location: @event_custom_view }
      else
				gon.load_js_event_custom_view_form = true
				gon.event_id = @event_custom_view.event_id
				gon.shape_type_id = @event_custom_view.shape_type_id
				gon.descendant_shape_type_id = @event_custom_view.descendant_shape_type_id
        format.html { render action: "new" }
        format.json { render json: @event_custom_view.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event_custom_view = EventCustomView.find(params[:id])

    respond_to do |format|
      if @event_custom_view.update_attributes(params[:event_custom_view])
        format.html { redirect_to event_custom_views_path, notice: 'Event Custom View was successfully updated.' }
        format.json { head :ok }
      else
				gon.load_js_event_custom_view_form = true
				gon.event_id = @event_custom_view.event_id
				gon.shape_type_id = @event_custom_view.shape_type_id
				gon.descendant_shape_type_id = @event_custom_view.descendant_shape_type_id
        format.html { render action: "edit" }
        format.json { render json: @event_custom_view.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event_custom_view = EventCustomView.find(params[:id])
    @event_custom_view.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :ok }
    end
  end
end
