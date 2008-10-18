require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  has_many :accounts, :foreign_key => 'owner_id'
  
  named_scope :active, :conditions => ['state != ?','inactive']
  named_scope :admins, :conditions => {:state => 'admin'}

  # Validations
  validates_format_of :name, :with => RE_NAME_OK, :message => MSG_NAME_BAD, :allow_nil => true
  validates_length_of :name, :maximum => 100
  #validates_presence_of :email, :if => :not_using_openid?
  #validates_length_of :email, :within => 6..100, :if => :not_using_openid?
  #validates_uniqueness_of :email, :case_sensitive => false, :if => :not_using_openid?
  #validates_format_of :email, :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD, :if => :not_using_openid?
  validates_uniqueness_of :identity_url
  validate :normalize_identity_url
  
  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :name, :identity_url

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = User.active.find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  def admin?
    state == 'admin'
  end
  
  def activate!
    self.state = 'active' if self.state == 'inactive'
    save!
  end

  def default_account
    accounts.find(attributes['default_account']) || accounts.find(:first)
  end

  def self.find_or_create_by_identity_url(identity_url, reg_data)
    user = User.find_by_identity_url identity_url
    unless user
      user = self.create!(:identity_url => identity_url, :name => reg_data['nickname'], :email => reg_data['email'])
    end
    user
  end
  
  # Overwrite password_required for open id
  def password_required?
    false
  end

  protected
    
  def normalize_identity_url
    self.identity_url = OpenIdAuthentication.normalize_url(identity_url)
  rescue URI::InvalidURIError
    errors.add_to_base("Invalid OpenID URL")
  end
end