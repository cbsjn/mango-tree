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
      flash[:warning] = @user.errors.full_messages
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
    @state = SecureRandom.uuid
    @redirect_uri = 'http://localhost:3000/quick_books/oauth_callback'
    @customers = Customer.where('created_at >= ?', 2.week.ago)
    @reservations = Reservation.where('created_at >= ?', 2.week.ago)
  end

  def oauth2_client
    Rack::OAuth2::Client.new(
      identifier: OAUTH_CONSUMER_KEY,
      secret: OAUTH_CONSUMER_SECRET,
      redirect_uri: "http://localhost:3000/quick_books/oauth_callback",
      authorization_endpoint: "https://appcenter.intuit.com/connect/oauth2",
      token_endpoint: "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer"
    )
  end

  def update
    first_name = params[:user][:first_name]
    mobile = params[:user][:mobile]
    password = params[:user][:password]
    if first_name.present? && mobile.present? && password.present?
      name = first_name.split(' ')
      first_name = name[0]
      last_name = name[1..4].join(' ')
      encrypted_pwd = User.encrypt(password)
      current_user.update_attributes(first_name: first_name, last_name: last_name, mobile: mobile, password: encrypted_pwd)
      flash[:notice] = 'User details have been updated successfully.'
    else
      flash[:warning] = 'Insufficient parameters'
    end
    render 'edit'
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