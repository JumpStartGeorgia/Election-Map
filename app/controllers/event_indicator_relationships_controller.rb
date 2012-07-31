class EventIndicatorRelationshipsController < ApplicationController
  before_filter :authenticate_user!
	cache_sweeper :event_indicator_relationship_sweeper, :only => [:create, :update, :destroy]

  def index
		@events = Event.get_all_events.includes(:event_indicator_relationships)
  end

	def show
		@event = Event.where(:id => params[:id]).with_translations(I18n.locale).includes(:event_indicator_relationships).first
	end

  def new
#    @event_custom_view = EventCustomView.new
  end

  def edit
#    @event_custom_view = EventCustomView.find(params[:id])
  end

  # POST /event_indicator_relationships
  # POST /event_indicator_relationships.json
  def create
#    @event_custom_view = EventCustomView.new(params[:event_custom_view])

    respond_to do |format|
      if @event_custom_view.save
        format.html { redirect_to event_custom_views_path, notice: 'Event Custom View was successfully created.' }
        format.json { render json: @event_custom_view, status: :created, location: @event_custom_view }
      else
        format.html { render action: "new" }
        format.json { render json: @event_custom_view.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /event_indicator_relationships/1
  # PUT /event_indicator_relationships/1.json
  def update
#    @event_custom_view = EventCustomView.find(params[:id])

    respond_to do |format|
      if @event_custom_view.update_attributes(params[:event_custom_view])
        format.html { redirect_to event_custom_views_path, notice: 'Event Custom View was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @event_custom_view.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_indicator_relationships/1
  # DELETE /event_indicator_relationships/1.json
  def destroy
#    @event_custom_view = EventCustomView.find(params[:id])
#    @event_custom_view.destroy

    respond_to do |format|
      format.html { redirect_to event_indicator_relationships_url }
      format.json { head :ok }
    end
  end
end
