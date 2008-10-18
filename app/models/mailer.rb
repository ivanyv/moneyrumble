class Mailer < ActionMailer::Base
  def signup_notification(user, host)
    setup_email(user)
    @subject << 'Please activate your new account'
    @body[:url] = "http://#{host}/activate/#{user.activation_code}"
  end
  
  def activation(user, host)
    setup_email(user)
    @subject << 'Your account has been activated!'
    @body[:url] = "http://#{host}"
  end
  
  protected
  
  def setup_email(user)
    @recipients = "#{user.email}"
    @from = APP_CONFIG[:admin_email]
    @subject = "[#{APP_CONFIG[:site_name]}] "
    @sent_on = Time.now
    @body[:user] = user
  end
end
