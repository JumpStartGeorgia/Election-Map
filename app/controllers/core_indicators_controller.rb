class CoreIndicatorsController < ApplicationController
  before_filter :authenticate_user!
	cache_sweeper :core_indicator_sweeper, :only => [:create, :update, :destroy]

  # GET /core_indicators
  # GET /core_indicators.json
  def index
    @core_indicators = CoreIndicator.order_by_type_name

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @core_indicators }
    end
  end

  # GET /core_indicators/colors
  def colors
    @core_indicators = CoreIndicator.with_colors

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @core_indicators }
    end
  end

  # GET /core_indicators/1
  # GET /core_indicators/1.json
  def show
    @core_indicator = CoreIndicator.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @core_indicator }
    end
  end

  # GET /core_indicators/new
  # GET /core_indicators/new.json
  def new
    @core_indicator = CoreIndicator.new
    @core_indicators = CoreIndicator.all
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.length.times {@core_indicator.core_indicator_translations.build}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @core_indicator }
    end
  end

  # GET /core_indicators/1/edit
  def edit
    @core_indicator = CoreIndicator.find(params[:id])
    @core_indicators = CoreIndicator.all
  end

  # POST /core_indicators
  # POST /core_indicators.json
  def create
    @core_indicator = CoreIndicator.new(params[:core_indicator])

    respond_to do |format|
      if @core_indicator.save
        format.html { redirect_to @core_indicator, notice: 'Core indicator was successfully created.' }
        format.json { render json: @core_indicator, status: :created, location: @core_indicator }
      else
		    @core_indicators = CoreIndicator.all
        format.html { render action: "new" }
        format.json { render json: @core_indicator.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /core_indicators/1
  # PUT /core_indicators/1.json
  def update
    @core_indicator = CoreIndicator.find(params[:id])

		# ancestry does not like "", so must reset the value to nil
		params[:core_indicator][:ancestry] = nil if params[:core_indicator][:ancestry] == ""

    respond_to do |format|
      if @core_indicator.update_attributes(params[:core_indicator])
        format.html { redirect_to @core_indicator, notice: 'Core indicator was successfully updated.' }
        format.json { head :ok }
      else
		    @core_indicators = CoreIndicator.all
logger.debug "++++++++ errors = #{@core_indicator.errors.inspect}"
        format.html { render action: "edit" }
        format.json { render json: @core_indicator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /core_indicators/1
  # DELETE /core_indicators/1.json
  def destroy
    @core_indicator = CoreIndicator.find(params[:id])
    @core_indicator.destroy

    respond_to do |format|
      format.html { redirect_to core_indicators_url }
      format.json { head :ok }
    end
  end
end
