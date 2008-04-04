require 'digest/sha1'
require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies") rescue nil

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
  
  def login=(value)
    @login = value.downcase unless value.nil?
  end
  
  def name
    "#{first_name} #{last_name}"
  end
  
  def handle
    self.login
  end
  
  def enter
    self.active = true
    self.save
    
    UserEnteredEvent.new(self).enqueue_for_all_active_users
  end
  
  def leave(reason = 'Logout')
    self.active = false
    self.save
    
    UserLeftEvent.new(self, 'Logout').enqueue_for_all_active_users
  end
end

