class SavedSearchesController < ApplicationController

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
    @search = SavedSearch.find(params[:id].to_i)

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
    @search = SavedSearch.find(params[:id].to_i)

    if @search
      redirect_to saved_searches_path unless @current_user.id == @search.user.id
    else
      redirect_to saved_searches_path
    end
  end

  def edit
    @search = SavedSearch.find(params[:id])
  end

  def update
    @search = SavedSearch.find(params[:id])

    if @search && @current_user.id == @search.user.id
      if params.key?(:search)

        if params[:search].is_a?(String)
          params[:search] = JSON.parse(params[:search])
        end

        @search.search = params[:search]
      end

      if params.has_key?(:public)
        @search.public = params[:public]
      end

      if @search.save
        render :json => @search
      else
        render :json => { :error => @search.errors }
      end
    else
      render :json => {}
    end
  end

  def title
    @search = SavedSearch.find(params[:id])

    return unless @search && @current_user.id == @search.user.id

    @search.title = params[:title] if params.key?(:title)

    if params.key?(:search)
      if params[:search].is_a?(String)
        params[:search] = JSON.parse(params[:search])
      end
      @search.search = params[:search]
    end

    if @search.save
      render text: @search.title
    else
      render json: @search.errors
    end
  end

  def destroy
    @search = SavedSearch.find(params[:id])

    respond_to do |format|
      if @search && @current_user.id == @search.user.id
        if @search.destroy
          format.html { redirect_to saved_searches_path, :flash => { :success => "Search `#{@search.title}` removed successfully." } }
        else
          format.html { redirect_to saved_searches_path, :flash => { :error => "Failed to remove search `#{@search.title}` successfully" } }
        end
      else
        format.html { redirect_to saved_searches_path }
      end
    end
  end

  private

  def search_params
    params.require(:search).permit(:title, :public, :user_id)
  end
end
