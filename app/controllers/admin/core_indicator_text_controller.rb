class Admin::CoreIndicatorTextController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:indicator_editor])
  end
	cache_sweeper :core_indicator_sweeper, :only => [:create, :update, :destroy]

  # GET /core_indicators
  # GET /core_indicators.json
  def index
    @core_indicators = CoreIndicator.for_profiles

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @core_indicators }
    end
  end

  # GET /core_indicators/1/edit
  def edit
    @core_indicator = CoreIndicator.for_profiles.readonly(false).find_by_id(params[:id])

    if @core_indicator.present?
      if request.post?
        respond_to do |format|
          if @core_indicator.update_attributes(params[:core_indicator])
				    msg = I18n.t('app.msgs.success_updated', :obj => I18n.t('app.common.core_indicator'))
				    send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg))
            format.html { redirect_to admin_core_indicator_text_path, notice: msg }
            format.json { head :ok }
          else
		        @core_indicators = CoreIndicator.all
    logger.debug "++++++++ errors = #{@core_indicator.errors.inspect}"
            format.html { render action: "edit" }
            format.json { render json: @core_indicator.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @core_indicator }
        end
      end
    else
			# no page was found, send back to home
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to admin_core_indicator_text_path
    end
  end

end
