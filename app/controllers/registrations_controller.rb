class RegistrationsController < Devise::RegistrationsController
  # TODO: delete
  # def new
  #   build_resource({})
  #   render_with_scope :new
  # end

  # TODO: delete
  # def create
  #   build_resource
  #
  #   if resource.save
  #     redirect_to edit_user_registration_path, notice: 'Successfully created user.'
  #   else
  #     clean_up_passwords(resource)
  #     render_with_scope :new
  #   end
  # end

  def update
    method = if Snorby::CONFIG[:authentication_mode] == 'database'
               'update_with_password'
             else
               'update'
             end

    if resource.send(method, user_params)
      set_flash_message :notice, :updated
      redirect_to edit_user_registration_path
    else
      clean_up_passwords(resource)
      render :edit
    end
  end

  private

  def user_params
    attributes = [:name, :email, :accept_notes, :per_page_count, :timezone,
                  :email_reports, :password, :password_confirmation,
                  :current_password]
    attributes << :admin if current_user.admin
    params.require(:user).permit(attributes)
  end
end
