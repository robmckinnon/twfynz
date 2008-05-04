class TrackingsController < ApplicationController
  # GET /trackings
  # GET /trackings.xml
  def index
    @trackings = Tracking.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trackings.to_xml }
    end
  end

  # GET /trackings/1
  # GET /trackings/1.xml
  def show
    @tracking = Tracking.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tracking.to_xml }
    end
  end

  # GET /trackings/new
  # GET /trackings/new.xml
  def new
    @tracking = Tracking.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tracking }
    end
  end

  # GET /trackings/1;edit
  def edit
    @tracking = Tracking.find(params[:id])
  end

  # POST /trackings
  def create
    if current_user
      @tracking = Tracking.new(params[:tracking])
      tracking = Tracking.from_user_and_item(current_user, @tracking.item)
      if @tracking.tracking_on
        tracking.destroy if tracking
        @tracking.user = current_user
        if @tracking.save
          # render :text => 'Tracking was successfully created.'
          trackings = Tracking.all_for_item @tracking.item, current_user
          render :partial => 'trackings', :object => trackings
        else
          render :text => 'Tracking not saved.'
        end
      else
        if tracking
          tracking.destroy
          # render :text => 'Tracking offed!'
          trackings = Tracking.all_for_item @tracking.item
          render :partial => 'trackings', :object => trackings
        else
          render :text => 'Tracking not found to destroy.'
        end
      end
    else
      render :template => 'trackings/login_required_message', :layout => false
    end
  end

  # PUT /trackings/1
  # PUT /trackings/1.xml
  def update
    @tracking = Tracking.find(params[:id])

    respond_to do |format|
      if @tracking.update_attributes(params[:tracking])
        flash[:notice] = 'Tracking was successfully updated.'
        format.html { redirect_to tracking_url(@tracking) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tracking.errors }
      end
    end
  end

  # DELETE /trackings/1
  # DELETE /trackings/1.xml
  def destroy
    @tracking = Tracking.find(params[:id])
    @tracking.destroy

    respond_to do |format|
      format.html { redirect_to(trackings_url) }
      format.xml  { head :ok }
    end
  end
end
