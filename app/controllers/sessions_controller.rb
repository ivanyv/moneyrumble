class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create
  skip_before_filter :login_required, :only => [:new, :create]
  
  def new
    @accounts = Account.demo
  end

  def create
    @accounts = Account.demo
    logout_keeping_session!
    open_id_authentication
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(root_path)
  end
  
  def open_id_authentication
    authenticate_with_open_id params[:openid_url], :optional => [ :nickname, :email ] do |result, identity_url, reg|
      if result.successful?
        begin
          user = User.find_or_create_by_identity_url(identity_url, reg.data)
        rescue => ex
          notify_hoptoad(ex)
          flash[:error] = 'We\'re sorry but an error prevented me from creating your account. Yeah, I know... I\'ll fix it ASAP :)'
          @rememer_me = params[:remember_me]
          render :action => :new
        else
          self.current_user = user
          successful_login
        end
      else
        flash[:error] = result.message || "Sorry no user with that identity URL exists"
        @rememer_me = params[:remember_me]
        render :action => :new
      end
    end
  end

  protected
  
  def successful_login
    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie! new_cookie_flag
    redirect_back_or_default(root_path)
    flash[:notice] = "Logged in successfully"
  end

  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
