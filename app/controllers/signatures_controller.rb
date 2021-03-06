class SignaturesController < ApplicationController
  before_filter :require_administrative_privileges
  helper_method :sort_column, :sort_direction

  def index
    params[:sort] = sort_column
    params[:direction] = sort_direction
    @signatures = Signature.sorty(params)
  end

  # TODO: Check if neccessary
  # def update
  #   @signature = Signature.find(params[:id])
  #   if @signature.update(params[:signature])
  #     redirect_to signatures_path, notice: 'Signature Updated Successfully.'
  #   else
  #     render action: 'edit', notice: 'Error: Unable To Save Record.'
  #   end
  # end
  #
  # def edit
  #   @signature = Signature.find(params[:id])
  # end
  #
  # def destroy
  #   @signature = signature.find(params[:id])
  #   @signature.destroy
  #   redirect_to signatures_path, notice: 'Signature Removed Successfully.'
  # end

  def search
    @total ||= Event.count

    if params[:q]
      render json: {
        signatures: Signature.where('sig_name like ?', "%#{params[:q]}%").limit(50),
        total: @total
      }
    else
      render json: { signatures: [] }
    end
  end

  private

  def sort_column
    return :events_count unless params.key?(:sort)
    params[:sort].to_sym
  end

  def sort_direction
    if %w(asc desc).include?(params[:direction].to_s)
      params[:direction].to_sym
    else
      :desc
    end
  end
end
