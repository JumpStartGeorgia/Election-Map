class LiveEventsController < ApplicationController
  before_filter :authenticate_user!

  # GET /live_events
  # GET /live_events.json
  def index
    @live_events = LiveEvent.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @live_events }
    end
  end

  # GET /live_events/1
  # GET /live_events/1.json
  def show
    @live_event = LiveEvent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @live_event }
    end
  end

  # GET /live_events/new
  # GET /live_events/new.json
  def new
    @live_event = LiveEvent.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @live_event }
    end
  end

  # GET /live_events/1/edit
  def edit
    @live_event = LiveEvent.find(params[:id])
  end

  # POST /live_events
  # POST /live_events.json
  def create
    @live_event = LiveEvent.new(params[:live_event])

    respond_to do |format|
      if @live_event.save
        format.html { redirect_to @live_event, notice: 'Live event was successfully created.' }
        format.json { render json: @live_event, status: :created, location: @live_event }
      else
        format.html { render action: "new" }
        format.json { render json: @live_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /live_events/1
  # PUT /live_events/1.json
  def update
    @live_event = LiveEvent.find(params[:id])

    respond_to do |format|
      if @live_event.update_attributes(params[:live_event])
        format.html { redirect_to @live_event, notice: 'Live event was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @live_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /live_events/1
  # DELETE /live_events/1.json
  def destroy
    @live_event = LiveEvent.find(params[:id])
    @live_event.destroy

    respond_to do |format|
      format.html { redirect_to live_events_url }
      format.json { head :ok }
    end
  end
end
