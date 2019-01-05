class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user

  def init_session(obj)
    session[:id] = obj.id
    session[:user_name] = "#{obj.first_name} #{obj.last_name}"
    session[:email] = obj.email
    session[:role] = User::ROLES.key(obj.role_id)
  end

  def current_user
    session[:id].present? ?  User.find(session[:id]) : []
  end
end
