class IndicatorScalesController < ApplicationController
  before_filter :authenticate_user!

  # GET /indicator_scales
  # GET /indicator_scales.json
  def index
    @indicator_scales = IndicatorScale.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @indicator_scales }
    end
  end

  # GET /indicator_scales/1
  # GET /indicator_scales/1.json
  def show
    @indicator_scale = IndicatorScale.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @indicator_scale }
    end
  end

  # GET /indicator_scales/new
  # GET /indicator_scales/new.json
  def new
    @indicator_scale = IndicatorScale.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    @locales.length.times {@indicator_scale.indicator_scale_translations.build}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @indicator_scale }
    end
  end

  # GET /indicator_scales/1/edit
  def edit
    @indicator_scale = IndicatorScale.find(params[:id])
  end

  # POST /indicator_scales
  # POST /indicator_scales.json
  def create
    @indicator_scale = IndicatorScale.new(params[:indicator_scale])

    respond_to do |format|
      if @indicator_scale.save
        format.html { redirect_to @indicator_scale, notice: 'Indicator scale was successfully created.' }
        format.json { render json: @indicator_scale, status: :created, location: @indicator_scale }
      else
        format.html { render action: "new" }
        format.json { render json: @indicator_scale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /indicator_scales/1
  # PUT /indicator_scales/1.json
  def update
    @indicator_scale = IndicatorScale.find(params[:id])

    respond_to do |format|
      if @indicator_scale.update_attributes(params[:indicator_scale])
        format.html { redirect_to @indicator_scale, notice: 'Indicator scale was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @indicator_scale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indicator_scales/1
  # DELETE /indicator_scales/1.json
  def destroy
    @indicator_scale = IndicatorScale.find(params[:id])
    @indicator_scale.destroy

    respond_to do |format|
      format.html { redirect_to indicator_scales_url }
      format.json { head :ok }
    end
  end

    # GET /indicator_scales/upload
    # GET /indicator_scales/upload.json
    def upload
  		if request.post? && params[:file].present?
  			if params[:file].content_type == "text/csv" || params[:file].content_type == "text/plain"
  		    msg = IndicatorScale.build_from_csv(params[:file], params[:delete_records].nil? ? nil : true)
          if msg.nil? || msg.length == 0
            # no errors, success!
  					flash[:notice] = "Your file was successfully processed!"
  		      redirect_to upload_indicator_scales_path #GET
          else
            # errors
  					flash[:notice] = "Errors were encountered and no records were saved.  The problem was the following: #{msg}"
  		      redirect_to upload_indicator_scales_path #GET
          end 
  			else
  				flash[:notice] = "Your file must be a CSV or tab-delimited txt format."
          redirect_to upload_indicator_scales_path #GET
  			end
  		end
    end


    # GET /indicator_scales/export
    def export
      filename ="indicator_sacles_template"
      csv_data = CSV.generate(:col_sep=>',') do |csv|
        csv << IndicatorScale.csv_all_header
      end 
      send_data csv_data,
        :type => 'text/csv; charset=utf-8; header=present',
        :disposition => "attachment; filename=#{filename}.csv"
    end 

end
