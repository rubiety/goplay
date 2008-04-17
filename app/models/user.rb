require 'digest/sha1'
require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies") rescue nil

# == User
# Represents a user in the system.  Activity is stored using the +active+ flag
# which should be kept current for accurate user list information.
# 
# === Entering & Leaving
# User entering and leaving is handled with the +enter!+ and +leave!+ methods
# which take care of broadcasting the appropriate events to all active clients as 
# well as updating the aforementioned +active+ flag. 
# 
# === Suspending Users
# Users can also be suspended 
# 
class User < DataMapper::Base
  include AuthenticatedSystem::Model
  
  attr_accessor :password, :password_confirmation
  
  property :first_name, :string
  property :last_name, :string
  property :login, :string
  property :admin, :boolean
  property :email, :string
  property :description, :text, :lazy => false
  property :crypted_password, :string
  property :salt, :string
  property :remember_token_expires_at, :datetime
  property :remember_token, :string
  property :active, :boolean
  property :created_at, :datetime
  property :updated_at, :datetime
  property :last_login_at, :datetime
  property :suspended_at, :datetime
  property :suspended_reason, :text
  property :last_pinged_at, :datetime
  
  has_many :events
  has_many :messages
  
  validates_length_of :login, :within => 3..40
  validates_uniqueness_of :login
  validates_presence_of :email
  validates_length_of :email, :within => 3..100
  validates_uniqueness_of :email
  validates_presence_of :password, :if => lambda { password_required? }
  validates_presence_of :password_confirmation, :if => lambda { password_required? }
  validates_length_of :password, :within => 4..40, :if => lambda { password_required? }
  validates_confirmation_of :password, :groups => :create
  validates_presence_of :description
  
  before_save :encrypt_password
  
  # Easy Record Retrieval by Login
  def self.with_login_of(login)
    self.first(:login => login)
  end
  
  def login=(value)
    @login = value.downcase unless value.nil?
  end
  
  # User full name
  def name
    "#{first_name} #{last_name}"
  end
  
  # User handle - for now defaults ot login
  def handle
    self.login
  end
  
  # Hash Representation
  def to_hash
    {
      :id => self.id,
      :name => self.name,
      :description => self.description
    }
  end
  
  # Makes the user active and broadcasts a user entered event
  def enter!
    self.last_login_at = Time.now
    self.last_pinged_at = Time.now
    self.active = true
    self.save
    
    UserEnteredEvent.new(self).enqueue_for_all_active_users(:except => self.id)
    self
  end
  
  # Makes the user inactive and broadcasts a user left event
  def leave!(reason = 'Logout')
    self.active = false
    self.save
    
    UserLeftEvent.new(self, 'Logout').enqueue_for_all_active_users(:except => self.id)
    
    # TODO: End active games that the user was participating in...
    
    
    self
  end
  
  # Suspends a user, allowing him to not login with an optional error message
  def suspend!(reason = nil)
    self.active = false
    self.suspended_at = Time.now
    self.suspended_reason = reason
    self.save
    self
  end
  
  # Updates the last_pinged_at timestamp to keep the user "alive"
  def pinged!
    self.last_pinged_at = Time.now
    self.save
    self
  end
  
  # Force-leaves users who have not pinged in 30 seconds
  def self.sweep_stale_users!
    # Disabling this for debugging reasons:
    return true
    
    self.each(:active => true, :last_pinged_at.lt => Time.now - 30.seconds) do |stale_user|
      stale_user.leave!
    end
  end
end

