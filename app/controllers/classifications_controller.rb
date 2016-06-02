class ClassificationsController < ApplicationController

  before_filter :require_administrative_privileges

  def index
    @classifications = Classification.all
      .paginate(page: (params[:page] || 1).to_i, per_page: @current_user.per_page_count)
      .order('id ASC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @classifications }
    end
  end

  def show
    @classification = Classification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @classification }
    end
  end

  def new
    @classification = Classification.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @classification }
    end
  end

  def edit
    @classification = Classification.find(params[:id])
  end

  def create
    @classification = Classification.new(params[:classification])

    respond_to do |format|
      if @classification.save
        format.html { redirect_to(classifications_url, :notice => 'Classification was successfully created.') }
        format.xml  { render :xml => @classification, :status => :created, :location => @classification }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @classification.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @classification = Classification.find(params[:id])

    respond_to do |format|
      if @classification.update(params[:classification])
        format.html { redirect_to(classifications_url, :notice => 'Classification was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @classification.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @classification = Classification.find(params[:id])
    @classification.destroy!

    respond_to do |format|
      format.html { redirect_to(classifications_url) }
      format.xml  { head :ok }
    end
  end
end
