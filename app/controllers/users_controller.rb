class UsersController < ApplicationController
  before_action :require_administrative_privileges,
                only: [:index, :add, :new, :remove]

  def index
    @users =
      User.all.paginate(
        page: params[:page],
        per_page: @current_user.per_page_count
      ).order(id: :asc)
  end

  def new
    @user = User.new
  end

  def add
    @user = User.create(user_params)
    if @user.save
      redirect_to users_path
    else
      render action: 'new'
    end
  end

  def remove
    @user = User.find(params[:id])
    @user.destroy!
    redirect_to users_path, notice: 'Successfully Delete User'
  end

  def toggle_settings
    @user = User.find(params[:user_id])

    if @user.update(params[:user])
      render json: { success: 'User updated successfully.' }
    else
      render json: { error: 'Error while changing user attributes.' }
    end

  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation, :per_page_count,
                                 :timezone, :email_reports, :admin)
  end

end
