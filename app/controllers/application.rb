class ApplicationController < ActionController::Base
  include HoptoadNotifier::Catcher
  include AuthenticatedSystem

  helper :all # include all helpers, all the time
  protect_from_forgery :secret => 'bed782a6e150adacec6be6d6a2dbcc3c'
  filter_parameter_logging :password, :password_confirmation
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
  protected
  
  # Automatically respond with 404 for ActiveRecord::RecordNotFound
  def record_not_found
    render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404
  end
end

