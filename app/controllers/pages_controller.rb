class PagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:view]


  # GET /pages/view/:name
  # GET /pages/view/:name.json
  def view
    @page = Page.with_translations(I18n.locale).find_by_name(params[:name])

		if @page.nil?
			# no page was found, send back to home
			redirect_to root_path
		else
		  if !params[:layout].nil?
				render :layout => params[:layout]
		  else
		    respond_to do |format|
		      format.html # show.html.erb
		      format.json { render json: @page }
		    end
			end
		end
  end

  # GET /pages
  # GET /pages.json
  def index
    @pages = Page.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pages }
    end
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @page = Page.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.json
  def new
    @page = Page.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.length.times {@page.page_translations.build}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.find(params[:id])
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save
				msg = I18n.t('app.msgs.success_created', :obj => I18n.t('app.common.page'))
				send_status_update(msg)
        format.html { redirect_to @page, notice: page }
        format.json { render json: @page, status: :created, location: @page }
      else
        format.html { render action: "new" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
				msg = I18n.t('app.msgs.success_updated', :obj => I18n.t('app.common.page'))
				send_status_update(msg)
        format.html { redirect_to @page, notice: msg }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = Page.find(params[:id])
    @page.destroy

		msg = I18n.t('app.msgs.success_deleted', :obj => I18n.t('app.common.page'))
		send_status_update(msg)
    respond_to do |format|
      format.html { redirect_to pages_url }
      format.json { head :ok }
    end
  end
end
