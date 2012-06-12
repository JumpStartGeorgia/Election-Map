class ShapeTypesController < ApplicationController
  before_filter :authenticate_user!
	cache_sweeper :shape_type_sweeper, :only => [:create, :update, :destroy]

  # GET /shape_types
  # GET /shape_types.json
  def index
    @shape_types = ShapeType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shape_types }
    end
  end

  # GET /shape_types/1
  # GET /shape_types/1.json
  def show
    @shape_type = ShapeType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @shape_type }
    end
  end

  # GET /shape_types/new
  # GET /shape_types/new.json
  def new
    @shape_type = ShapeType.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.length.times {@shape_type.shape_type_translations.build}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shape_type }
    end
  end

  # GET /shape_types/1/edit
  def edit
    @shape_type = ShapeType.find(params[:id])
  end

  # POST /shape_types
  # POST /shape_types.json
  def create
    @shape_type = ShapeType.new(params[:shape_type])

		# get the parent shape type
		parent = ShapeType.find(params[:parent_shape])

    respond_to do |format|
			if parent.nil?
        format.html { render action: "new" }
        format.json { render json: @shape_type.errors, status: :unprocessable_entity }
			else
				# add the new shape type to the parent
		    if parent.children.create(params[:shape_type])
		      format.html { redirect_to @shape_type, notice: 'Shape type was successfully created.' }
		      format.json { render json: @shape_type, status: :created, location: @shape_type }
		    else
		      format.html { render action: "new" }
		      format.json { render json: @shape_type.errors, status: :unprocessable_entity }
		    end
	    end
    end
  end

  # PUT /shape_types/1
  # PUT /shape_types/1.json
  def update
    @shape_type = ShapeType.find(params[:id])

		# get the parent shape type
		parent = ShapeType.find(params[:parent_shape])

    respond_to do |format|
			if parent.nil?
	      format.html { render action: "edit" }
	      format.json { render json: @shape_type.errors, status: :unprocessable_entity }
			else
				# see if the parent shape changed
				anc_ary = @shape_type.ancestry.split("/")
				if (anc_ary.length == 1 && parent.id.to_s == anc_ary[0]) || parent.id.to_s == anc_ary[anc_ary.length-1]
					# parent shape did not change, do nothing
				else
					# parent shape did change.  update the ancestry value
					new_anc = parent.ancestor_ids.join("/")
					new_anc += "/" + parent.id.to_s
					params[:shape_type][:ancestry] = new_anc
				end

		    if @shape_type.update_attributes(params[:shape_type])
		      format.html { redirect_to @shape_type, notice: 'Shape type was successfully updated.' }
		      format.json { head :ok }
		    else
		      format.html { render action: "edit" }
		      format.json { render json: @shape_type.errors, status: :unprocessable_entity }
		    end
	    end
    end
  end

  # DELETE /shape_types/1
  # DELETE /shape_types/1.json
  def destroy
    @shape_type = ShapeType.find(params[:id])
    @shape_type.destroy

    respond_to do |format|
      format.html { redirect_to shape_types_url }
      format.json { head :ok }
    end
  end
end
