# Handles signing in and out of the application.
# Relies on OmniAuth[https://github.com/intridea/omniauth] for the heavy lifiting.
class SessionsController < ApplicationController
  do_not_require_login
  skip_authorization_check

  def new
    @user = User.new
  end

  def create
    respond_to do |format|
      if @user = login(credentials[:email], credentials[:password])
        format.html do
          redirect_back_or_to(:root)
        end
      else
        @user = User.new
        format.html do
          flash.now[:alert] = "The email and password you entered are not valid."
          render action: "new", status: :unprocessable_entity
        end
      end
    end
  end

  def create_oauth
    find_and_store_identity! do |user_identity, new_identity, new_user|
      redirect_to root_url
    end
    auto_login user_identity.user unless logged_in?
  rescue AuthIdentityAlreadyTakenError
    redirect_to root_url, notice: "That #{provider_name} account "\
      "is already taken by another user."
  end

  def failure_oauth
    redirect_to root_url, notice: failure_message
  end

  def destroy
    logout
    redirect_to root_url
  end

  private

  def authdata
    request.env["omniauth.auth"]
  end

  def user_identity
    @user_identity ||= UserIdentity.find_or_initialize_by(
      provider: authdata['provider'],
      uid: authdata['uid'],
    )
  end

  def existing_user
    @existing_user ||= user_identity.user
  end

  def new_user
    @new_user ||= User.new
  end

  def find_and_store_identity!
    UserIdentity.transaction do
      if logged_in? && user_identity.user && user_identity.user != current_user
        fail AuthIdentityAlreadyTakenError
      end
      user_identity.data = authdata
      user_identity.user = current_user || existing_user || new_user
      if block_given?
        yield(user_identity, !user_identity.persisted?, !user_identity.user.persisted?)
      end
      user_identity.user.save!
      user_identity.save!
    end
  end

  def failure_message
    case params[:message]
    when 'invalid_credentials'
      "Sorry, something went wrong during authentication with #{params[:strategy].to_s.titleize}."
    end
  end

  def provider_name
    authdata['provider'].to_s.titleize
  end

  def credentials
    params.require(:user).permit(:email, :password)
  end
end
