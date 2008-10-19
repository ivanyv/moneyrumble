class ApplicationController < ActionController::Base
  include HoptoadNotifier::Catcher
  include AuthenticatedSystem

  before_filter :login_required
  before_filter :load_sidebar

  helper :all # include all helpers, all the time
  protect_from_forgery :secret => 'bed782a6e150adacec6be6d6a2dbcc3c'
  filter_parameter_logging :password, :password_confirmation
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found if RAILS_ENV == 'production'
  
  protected
  
  # Automatically respond with 404 for ActiveRecord::RecordNotFound
  def record_not_found
    render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404
  end

  def load_sidebar
    return unless logged_in?
    
    @all_accounts = current_user.accounts.find(:all, :include => [ :sub_accounts ] )

    @accounts = []
    @all_accounts.each {|a| @accounts << a unless a.parent_id }
  end
end