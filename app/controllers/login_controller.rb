class LoginController < ApplicationController
  layout "empty", only: [:index,:new]
  before_filter :clear_notification

  def index
    unless session[:email].present?
      render 'login/index'
    else
      redirect_to dashboard_login_index_path and return
    end
  end

  def new
    @user = User.new
  end

  def sign_up
    @user = User.create_user(user_param)
    if @user.save
      init_session(@user)
      flash[:notice] = 'User details have been created successfully.'
      redirect_to dashboard_login_index_path
    else
      flash['warning'] = @user.errors.full_messages
      redirect_to new_login_path
    end
  end

  def sign_in
    if request.method.eql? 'POST'
      user_info = User.authenticate(params[:email], params[:password])
      if user_info.present?
        init_session(user_info)
        redirect_to dashboard_login_index_path and return
      else
        flash['warning'] = 'Incorrect Username or Password!'
        #render 'login/index'
        redirect_to root_url
      end
    else
      redirect_to root_url if session[:id].present?
    end
  end

  def sign_out
    reset_session
    redirect_to root_url
  end

  def dashboard

  end

  private
  # Using a private method to encapsulate the permissible parameters is
  # just a good pattern since you'll be able to reuse the same permit
  # list between create and update. Also, you can specialize this method
  # with per-user checking of permissible attributes.
  def user_param
    params.require(:user).permit(:password, :confirm_password, :first_name, :last_name,:age,:email,:mobile,:landline,:emergency_contact_number,:role_id)
  end

  def clear_notification
    #flash['warning'] = nil
  end
end