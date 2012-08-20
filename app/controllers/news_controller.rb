class NewsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
	require 'data_archive'

  # GET /news
  # GET /news.json
  def index
    @news = News.recent.with_translations(I18n.locale).paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @news }
    end
  end

=begin
  # GET /news/1
  # GET /news/1.json
  def show
    @news = News.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @news }
    end
  end
=end

  # GET /news/new
  # GET /news/new.json
  def new
    @news = News.new
		@news_types = News::NEWS_TYPES
    # get list of data archive folders that do not have news tied to them already
		@availabe_archives = available_archives

    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    I18n.available_locales.length.times {@news.news_translations.build}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @news }
    end
  end

  # GET /news/1/edit
  def edit
    @news = News.find(params[:id])
		@news_types = News::NEWS_TYPES
    # get list of data archive folders that do not have news tied to them already
		@availabe_archives = available_archives
  end

  # POST /news
  # POST /news.json
  def create
    @news = News.new(params[:news])

    respond_to do |format|
      if @news.save
        format.html { redirect_to @news, notice: 'News was successfully created.' }
        format.json { render json: @news, status: :created, location: @news }
      else
        format.html { render action: "new" }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /news/1
  # PUT /news/1.json
  def update
    @news = News.find(params[:id])

    respond_to do |format|
      if @news.update_attributes(params[:news])
        format.html { redirect_to @news, notice: 'News was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news/1
  # DELETE /news/1.json
  def destroy
    @news = News.find(params[:id])
    @news.destroy

    respond_to do |format|
      format.html { redirect_to news_index_url }
      format.json { head :ok }
    end
  end

	protected

	def available_archives
		available = []
		archives = DataArchive.get_archives
		news = News.data_archives
logger.debug "/////////// archives count = #{archives.length}"
logger.debug "/////////// news count = #{news.length}"

		# now determine which archives do not have a news story
		if news && !news.empty?
logger.debug "/////////// available archives = #{available}"
			# news items with archives, find unused archives
			archives.select{|x| news.index{|n| n.data_archive_folder == x["folder"]}}.each do |archive|
				available << archive["date"]
			end
		else
logger.debug "/////////// no news items with archives"
			# there are no news items with archives
			archives.each do |archive|
				available << archive["date"]
			end
		end
logger.debug "/////////// available archives = #{available}"
		return available
	end
end
