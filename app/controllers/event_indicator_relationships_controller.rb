class EventIndicatorRelationshipsController < ApplicationController
  before_filter :authenticate_user!
	cache_sweeper :event_indicator_relationship_sweeper, :only => [:create, :update, :destroy]

  def render_js_blocks
		@counter = params[:counter].to_i+1
		@indicator_types = IndicatorType.get_summary_indicator_types_in_event(params[:id])
		@core_indicators = CoreIndicator.get_unique_indicators_in_event(params[:id])
		if params[:type]
			render :json => {
		    :html => (render_to_string :partial => "event_indicator_relationships/#{params[:type]}.html")
		  }
		end
  end

  def index
		@events = Event.get_all_events.includes(:event_indicator_relationships)
  end

	def show
		@event = Event.where(:id => params[:id]).with_translations(I18n.locale).includes(:event_indicator_relationships).order("event_indicator_relationships.indicator_type_id, event_indicator_relationships.core_indicator_id, event_indicator_relationships.sort_order").first
	end

  def new
    @event_indicator_relationships = []
    @event = Event.find(params[:id])
		@indicator_types = IndicatorType.get_summary_indicator_types_in_event(params[:id])
		@core_indicators = CoreIndicator.get_unique_indicators_in_event(params[:id])
		gon.load_js_event_indicator_relationship_form = true

    case params[:type]
      when "indicator"
        @unused_indicators = []
      when "indicator_type"
        @unused_indicator_types = []
    end
  end

  def edit
		if params[:indicator_type_id]
			@event_indicator_relationships = EventIndicatorRelationship.where(:event_id => params[:id],
					:indicator_type_id => params[:indicator_type_id])
		elsif params[:core_indicator_id]
			@event_indicator_relationships = EventIndicatorRelationship.where(:event_id => params[:id],
					:core_indicator_id => params[:core_indicator_id])
		else
			redirect_to event_indicator_relationships_path, notice: 'Please provide all parameters to edit a record.'
		end
    @event = Event.find(params[:id])
		@indicator_types = IndicatorType.get_summary_indicator_types_in_event(params[:id])
		@core_indicators = CoreIndicator.get_unique_indicators_in_event(params[:id])
		gon.load_js_event_indicator_relationship_form = true
  end

  # POST /event_indicator_relationships
  # POST /event_indicator_relationships.json
  def create
#    @event_indicator_relationship = EventCustomView.new(params[:event_indicator_relationship])

    respond_to do |format|
      if @event_indicator_relationship.save
        format.html { redirect_to event_indicator_relationships_path, notice: 'Event Custom View was successfully created.' }
        format.json { render json: @event_indicator_relationship, status: :created, location: @event_indicator_relationship }
      else
        @event = Event.find(params[:id])
				@indicator_types = IndicatorType.get_summary_indicator_types_in_event(params[:id])
				@core_indicators = CoreIndicator.get_unique_indicators_in_event(params[:id])
				gon.load_js_event_indicator_relationship_form = true
        format.html { render action: "new" }
        format.json { render json: @event_indicator_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /event_indicator_relationships/1
  # PUT /event_indicator_relationships/1.json
  def update
		if params[:indicator_type_id] && !params[:indicator_type_id].empty?
			@event_indicator_relationships = EventIndicatorRelationship.where(:event_id => params[:id],
					:indicator_type_id => params[:indicator_type_id])
		elsif params[:core_indicator_id] && !params[:core_indicator_id].empty?
			@event_indicator_relationships = EventIndicatorRelationship.where(:event_id => params[:id],
					:core_indicator_id => params[:core_indicator_id])
		else
			redirect_to event_indicator_relationships_path, notice: 'Please provide all parameters to edit a record.'
		end

    respond_to do |format|
			error_msgs = []
			EventIndicatorRelationship.transaction do
        # update existing records
				@event_indicator_relationships.each do |relationship|
					values = nil
					# look for the form data for this relationship
					params[:event_indicator_relationship].each_value do |v|
						if v["id"].to_s == relationship.id.to_s
							values = v
							break
						end
					end
					if values.nil?
logger.debug "++++++++++ no form data for this relationship, deleting id #{relationship.id}"
						# could not find relationship so it was deleted
						EventIndicatorRelationship.delete(relationship.id)
					elsif !relationship.update_attributes(values)
						# error saving the relationship
						raise ActiveRecord::Rollback
logger.debug "++++++++++ error = relationship.errors.inspect"
						error_msgs << relationship.errors.message
						break
					end
				end

        # add new records
				params[:event_indicator_relationship].each_value do |v|
					if v["id"].nil? || v["id"].empty? &&
					    ((!v["related_core_indicator_id"].nil? && !v["related_core_indicator_id"].empty?) ||
					    (!v["related_indicator_type_id"].nil? && !v["related_indicator_type_id"].empty?))
					  relationship = EventIndicatorRelationship.new(v)
					  relationship.event_id = params[:id]
					  relationship.core_indicator_id = params[:core_indicator_id] if !params[:core_indicator_id].empty?
					  relationship.indicator_type_id = params[:indicator_type_id] if !params[:indicator_type_id].empty?
            if !relationship.save
  						# error saving the relationship
  						raise ActiveRecord::Rollback
logger.debug "++++++++++ error = relationship.errors.inspect"
  						error_msgs << relationship.errors.message
            end
					end
				end

			end
      if error_msgs.empty?
        format.html { redirect_to event_indicator_relationship_path(params[:id]), notice: 'Event Custom View was successfully updated.' }
        format.json { head :ok }
      else
        @event = Event.find(params[:id])
				@indicator_types = IndicatorType.get_summary_indicator_types_in_event(params[:id])
				@core_indicators = CoreIndicator.get_unique_indicators_in_event(params[:id])
				gon.load_js_event_indicator_relationship_form = true
        format.html { render action: "edit" }
        format.json { render json: error_msgs, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_indicator_relationships/1
  # DELETE /event_indicator_relationships/1.json
  def destroy
#    @event_indicator_relationship = EventCustomView.find(params[:id])
#    @event_indicator_relationship.destroy

    respond_to do |format|
      format.html { redirect_to event_indicator_relationships_url }
      format.json { head :ok }
    end
  end
end
