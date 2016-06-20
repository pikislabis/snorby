class JobsController < ApplicationController
  before_filter :require_administrative_privileges
  before_action :set_job, except: :index

  def index
    @jobs = DelayedJob.all
    @process = Snorby::Worker.process

    respond_to do |format|
      format.html
      format.js
      format.xml  { render xml: @jobs }
    end
  end

  def last_error
    render layout: false
  end

  def handler
    render layout: false
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @job }
    end
  end

  def destroy
    if @job.blank?
      redirect_to jobs_url
    else
      @job.destroy
      respond_to do |format|
        format.html { redirect_to(jobs_url) }
        format.xml  { head :ok }
      end
    end
  end

  private

  def set_job
    @job = DelayedJob.find(params[:id])
  end
end
