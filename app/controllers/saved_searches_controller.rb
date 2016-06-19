class SavedSearchesController < ApplicationController

  before_action :set_saved_search, only: [:show, :view, :update, :title,
                                          :destroy]

  def index
    @searches =
      SavedSearch.where('user_id = ? OR public = ?', @current_user.id, true)
                 .paginate(page: (params[:page] || 1).to_i, per_page: @current_user.per_page_count)
                 .order(created_at: :ASC)
  end

  def new
    @search = SavedSearch.new
    render layout: false
  end

  def create
    return unless params.key?(:search)

    params[:search] = JSON.parse(params[:search]) if params[:search].is_a?(String)

    params[:search][:user_id] = @current_user.id

    @search = SavedSearch.new(search_params)
    @search.search = params[:search][:search]

    if @search.save
      render json: @search
    else
      render json: { error: @search.errors }
    end
  end

  def show
    if @search
      if @current_user.id == @search.user.id || @search.public
        render json: @search
      else
        render json: {}
      end
    else
      render json: {}
    end
  end

  def view
    if @search
      redirect_to saved_searches_path unless @current_user.id == @search.user.id
    else
      redirect_to saved_searches_path
    end
  end

  # TODO: delete action if not necessary
  # def edit
  #   @search = SavedSearch.find(params[:id])
  # end

  def update
    if @search && @current_user.id == @search.user.id
      if params.key?(:search)

        if params[:search].is_a?(String)
          params[:search] = JSON.parse(params[:search])
        end

        @search.search = params[:search]
      end

      @search.public = params[:public] if params.key?(:public)

      if @search.save
        render json: @search
      else
        render json: { error: @search.errors }
      end
    else
      render json: {}
    end
  end

  def title
    return unless @search && @current_user.id == @search.user.id

    @search.title = ActionController::Base.helpers.sanitize(params[:title]) if params.key?(:title)

    if @search.save
      render text: @search.title
    else
      render json: @search.errors
    end
  end

  def destroy
    respond_to do |format|
      if @search && @current_user.id == @search.user.id
        if @search.destroy
          format.html { redirect_to saved_searches_path, flash: { success: "Search `#{@search.title}` removed successfully." } }
        else
          format.html { redirect_to saved_searches_path, flash: { error: "Failed to remove search `#{@search.title}` successfully" } }
        end
      else
        format.html { redirect_to saved_searches_path }
      end
    end
  end

  private

  def set_saved_search
    @search = SavedSearch.find_by(id: params[:id].to_i)
  end

  def search_params
    params.require(:search).permit(:title, :public, :user_id)
  end
end
