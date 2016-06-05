class SeveritiesController < ApplicationController
  before_action :require_administrative_privileges

  def index
    @severities =
      Severity.all.paginate(
        page: (params[:page] || 1).to_i,
        per_page: @current_user.per_page_count
      ).order(id: :asc)
  end

  def new
    @severity = Severity.new
  end

  def create
    @severity = Severity.create(severity_params)
    if @severity.save
      redirect_to severities_path, notice: 'Severity Created Successfully.'
    else
      render action: 'new', notice: 'Error: Unable To Create Record.'
    end
  end

  def update
    @severity = Severity.find(params[:id])
    if @severity.update(params[:severity])
      redirect_to severities_path, notice: 'Severity Updated Successfully.'
    else
      render action: 'edit', notice: 'Error: Unable To Save Record.'
    end
  end

  def edit
    @severity = Severity.find(params[:id])
  end

  def destroy
    @severity = Severity.find(params[:id])
    @severity.destroy
    redirect_to severities_path, :notice => 'Severity Removed Successfully.'
  end

  private

  def severity_params
    params.require(:severity).permit(:name, :sig_id, :bg_color, :text_color)
  end
end
