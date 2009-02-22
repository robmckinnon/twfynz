require 'net/http'

class SubmissionsController < ApplicationController

  in_place_edit_for :submission, :submitter_url

  def index
    if admin?
      @submissions = Submission.paginate :page => params[:page]
      @submissions.each { |s| s.save! if (s.populate_submitter_id == 'yes') }
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @submissions }
      end
    else
      render :text => ''
    end
  end

  def show
    if admin?
      @submission = Submission.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @submission.to_xml }
      end
    else
      render :text => ''
    end
  end

  def new
    if admin?
      @submission = Submission.new

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @submission.to_xml }
      end
    else
      render :text => ''
    end
  end

  def edit
    if admin?
      @submission = Submission.find(params[:id])
    else
      render :text => ''
    end
  end

  def create
    if admin?
      @submission = Submission.new(params[:submission])

      respond_to do |format|
        if @submission.save
          flash[:notice] = 'Submission was successfully created.'
          format.html { redirect_to submission_url(@submission) }
          format.xml  { render :xml => @submission, :status => :created, :location => @submission }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @submission.errors }
        end
      end
    else
      render :text => ''
    end
  end

  def update_submission
    update
  end

  def update
    if admin?
      @submission = Submission.find(params[:id])
      @submission.update_attributes(params[:submission])
      @submission.reload
      render :partial => 'submissions/submission', :object => @submission
    else
      render :text => ''
    end
  end

  def destroy
    if admin?
      @submission = Submission.find(params[:id])
      @submission.destroy

      respond_to do |format|
        format.html { redirect_to(submissions_url) }
        format.xml  { head :ok }
      end
    else
      render :text => ''
    end
  end

end
