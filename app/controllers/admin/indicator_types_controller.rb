class Admin::IndicatorTypesController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:admin])
  end
	cache_sweeper :indicator_type_sweeper, :only => [:create, :update, :destroy]

  # GET /indicator_types
  # GET /indicator_types.json
  def index
    @indicator_types = IndicatorType.order("sort_order asc")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @indicator_types }
    end
  end

  # GET /indicator_types/1
  # GET /indicator_types/1.json
  def show
    @indicator_type = IndicatorType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @indicator_type }
    end
  end

  # GET /indicator_types/new
  # GET /indicator_types/new.json
  def new
    @indicator_type = IndicatorType.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.each do |locale|
			@indicator_type.indicator_type_translations.build(:locale => locale)
		end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @indicator_type }
    end
  end

  # GET /indicator_types/1/edit
  def edit
    @indicator_type = IndicatorType.find(params[:id])
  end

  # POST /indicator_types
  # POST /indicator_types.json
  def create
    @indicator_type = IndicatorType.new(params[:indicator_type])

    respond_to do |format|
      if @indicator_type.save
				msg = I18n.t('app.msgs.success_created', :obj => I18n.t('app.common.indicator_type'))
				send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg))
        format.html { redirect_to admin_indicator_type_path(@indicator_type), notice: msg }
        format.json { render json: @indicator_type, status: :created, location: @indicator_type }
      else
        format.html { render action: "new" }
        format.json { render json: @indicator_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /indicator_types/1
  # PUT /indicator_types/1.json
  def update
    @indicator_type = IndicatorType.find(params[:id])

    respond_to do |format|
      if @indicator_type.update_attributes(params[:indicator_type])
				msg = I18n.t('app.msgs.success_updated', :obj => I18n.t('app.common.indicator_type'))
				send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg))
        format.html { redirect_to admin_indicator_type_path(@indicator_type), notice: msg }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @indicator_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indicator_types/1
  # DELETE /indicator_types/1.json
  def destroy
    @indicator_type = IndicatorType.find(params[:id])
    @indicator_type.destroy

		msg = I18n.t('app.msgs.success_deleted', :obj => I18n.t('app.common.indicator_type'))
		send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg))
    respond_to do |format|
      format.html { redirect_to admin_indicator_types_url }
      format.json { head :ok }
    end
  end
end
