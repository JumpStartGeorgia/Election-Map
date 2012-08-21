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

		# turn the datetime picker js on
		# have to format dates this way so js datetime picker read them properly
		gon.edit_news = true
		gon.data_archive = @news_types[:data_archive]

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

		# turn the datetime picker js on
		# have to format dates this way so js datetime picker read them properly
		gon.edit_news = true
		gon.date_posted = @news.date_posted.strftime('%m/%d/%Y %H:%M') if !@news.date_posted.nil?
		gon.data_archive = @news_types[:data_archive]
  end

  # POST /news
  # POST /news.json
  def create
    @news = News.new(params[:news])

    respond_to do |format|
      if @news.save
        format.html { redirect_to news_index_path, notice: 'News was successfully created.' }
        format.json { render json: @news, status: :created, location: @news }
      else
				# turn the datetime picker js on
				# have to format dates this way so js datetime picker read them properly
				gon.edit_news = true
				gon.date_posted = @news.date_posted.strftime('%m/%d/%Y %H:%M') if !@news.date_posted.nil?
				gon.data_archive = @news_types[:data_archive]

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
        format.html { redirect_to news_index_path, notice: 'News was successfully updated.' }
        format.json { head :ok }
      else
				# turn the datetime picker js on
				# have to format dates this way so js datetime picker read them properly
				gon.edit_news = true
				gon.date_posted = @news.date_posted.strftime('%m/%d/%Y %H:%M') if !@news.date_posted.nil?
				gon.data_archive = @news_types[:data_archive]

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

	# get all archives and mark which ones already have news about them
	def available_archives
		available = []
		archives = DataArchive.get_archives
		news = News.data_archives

		if archives && !archives.empty?
			# now determine which archives do not have a news story
			if news && !news.empty?
				# news items with archives, determine which ones have news story
				archives.each do |archive|
					text = archive["date"]
					text << " *" if !news.index{|n| n.data_archive_folder == archive["folder"]}.nil?
					available << {:id => archive["folder"], :name => text}
				end
			else
				# there are no news items with archives
				archives.each do |archive|
					available << {:id => archive["folder"], :name => archive["date"]}
				end
			end
		end
		return available
	end
end
