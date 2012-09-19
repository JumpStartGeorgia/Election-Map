class EventIndicatorRelationshipsController < ApplicationController
  before_filter :authenticate_user!
	cache_sweeper :event_indicator_relationship_sweeper, :only => [:create, :update, :destroy]

  def render_js_blocks
		@counter = params[:counter].to_i+1
		load_form_variables
		if params[:type]
			render :json => {
		    :html => (render_to_string :partial => "event_indicator_relationships/#{params[:type]}.html")
		  }
		end
  end

  def index
		@events = Event.get_all_events_by_date.includes(:event_indicator_relationships)
  end

	def show
		load_form_variables

		@event = Event.where(:id => params[:id]).with_translations(I18n.locale).includes(:event_indicator_relationships).order("event_indicator_relationships.indicator_type_id, event_indicator_relationships.core_indicator_id, event_indicator_relationships.sort_order").first

	end

  def new
    @event_indicator_relationships = []
		load_form_variables
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
		load_form_variables
  end

  # POST /event_indicator_relationships
  # POST /event_indicator_relationships.json
  def create
    respond_to do |format|
			error_msgs = []
		  # add new records
			if params[:event_indicator_relationship]
				params[:event_indicator_relationship].each_value do |v|
					if v["id"].nil? || v["id"].empty? &&
							((!v["related_core_indicator_id"].nil? && !v["related_core_indicator_id"].empty?) ||
							(!v["related_indicator_type_id"].nil? && !v["related_indicator_type_id"].empty?))
						relationship = EventIndicatorRelationship.new(v)
						relationship.event_id = params[:id]
						relationship.core_indicator_id = params[:core_indicator_id] if params[:core_indicator_id] && !params[:core_indicator_id].empty?
						relationship.indicator_type_id = params[:indicator_type_id] if params[:indicator_type_id] && !params[:indicator_type_id].empty?
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
				msg = I18n.t('app.msgs.success_created', :obj => I18n.t('app.common.event_indicator_relationship'))
				send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg))
        format.html { redirect_to event_indicator_relationship_path(params[:id]), notice: msg }
        format.json { render json: @event_indicator_relationship, status: :created, location: @event_indicator_relationship }
      else
        load_form_variables
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
					if params[:event_indicator_relationship]
						params[:event_indicator_relationship].each_value do |v|
							if v["id"].to_s == relationship.id.to_s
								values = v
								break
							end
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
				if params[:event_indicator_relationship]
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

			end
      if error_msgs.empty?
				msg = I18n.t('app.msgs.success_updated', :obj => I18n.t('app.common.event_custom_view'))
				send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg))
        format.html { redirect_to event_indicator_relationship_path(params[:id]), notice: msg }
        format.json { head :ok }
      else
        load_form_variables
        format.html { render action: "edit" }
        format.json { render json: error_msgs, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_indicator_relationships/1
  # DELETE /event_indicator_relationships/1.json
  def destroy
#    @event_indicator_relationship = EventIndicatorRelationship.find(params[:id])
#    @event_indicator_relationship.destroy

		msg = I18n.t('app.msgs.success_deleted', :obj => I18n.t('app.common.event_custom_view'))
		send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg))
    respond_to do |format|
      format.html { redirect_to event_indicator_relationships_url }
      format.json { head :ok }
    end
  end


	protected

	def load_form_variables
    @event = Event.find(params[:id])
		@indicator_types = IndicatorType.get_summary_indicator_types_in_event(params[:id])
		@core_indicators = CoreIndicator.get_unique_indicators_in_event(params[:id])

		existing_indicator_relationships = EventIndicatorRelationship.core_indicator_ids_in_event(params[:id])
    @unused_indicators = Array.new(@core_indicators)
			.delete_if{|x| !existing_indicator_relationships.collect(&:core_indicator_id).index(x.id).nil?}
		existing_indicator_type_relationships = EventIndicatorRelationship.indicator_type_ids_in_event(params[:id])
    @unused_indicator_types = Array.new(@indicator_types)
			.delete_if{|x| !existing_indicator_type_relationships.collect(&:indicator_type_id).index(x.id).nil?}

		gon.load_js_event_indicator_relationship_form = true
logger.debug "unused inds = #{@unused_indicators}"
logger.debug "unused ind types = #{@unused_indicator_types}"
	end
end
