class LocalesController < ApplicationController
  before_filter :authenticate_user!
	cache_sweeper :locale_sweeper, :only => [:create, :update, :destroy]

  # GET /locales
  # GET /locales.json
  def index
    @locales = Locale.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @locales }
    end
  end

  # GET /locales/1
  # GET /locales/1.json
  def show
    @locale = Locale.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @locale }
    end
  end

  # GET /locales/new
  # GET /locales/new.json
  def new
    @locale = Locale.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @locale }
    end
  end

  # GET /locales/1/edit
  def edit
    @locale = Locale.find(params[:id])
  end

  # POST /locales
  # POST /locales.json
  def create
		# the params[:locale] is being used to keep track of the current users locale value
		# so we have to populate the new locale object by hand
    @locale = Locale.new({:language => params[:language], :name => params[:name]})

    respond_to do |format|
      if @locale.save
        format.html { redirect_to @locale, notice: 'Locale was successfully created.' }
        format.json { render json: @locale, status: :created, location: @locale }
      else
        format.html { render action: "new" }
        format.json { render json: @locale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /locales/1
  # PUT /locales/1.json
  def update
    @locale = Locale.find(params[:id])

    respond_to do |format|
			# the params[:locale] is being used to keep track of the current users locale value
			# so we have to populate the existing locale object by hand
      if @locale.update_attributes({:language => params[:language], :name => params[:name]})
        format.html { redirect_to @locale, notice: 'Locale was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @locale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locales/1
  # DELETE /locales/1.json
  def destroy
    @locale = Locale.find(params[:id])
    @locale.destroy

    respond_to do |format|
      format.html { redirect_to locales_url }
      format.json { head :ok }
    end
  end
end
