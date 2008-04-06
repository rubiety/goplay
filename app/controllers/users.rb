# == Users Controller
# Standard REST resource representing users in the system.  The 
# semantics of this are a bit nonstandard as this resource really 
# represents "active" users only - the only ones that matter as far 
# as the gaming system is concerned.
# 
# Also, although this is not a singular resource, this is effectively 
# a "singleton resource" of current - can only be invoked with an 
# id of "current".  The only exception is the show action which allows 
# you to see details about any user.
#
class Users < Application
  provides :xml, :yaml, :js
  
  before :login_required, :exclude => [:new, :create]
  before :fetch_active_users, :only => [:index]
  before :fetch_user, :only => [:show]
  before :fetch_current_user, :exclude => [:index, :show, :new, :create]
  
  # GET /users
  def index
    @message = Message.new
    display @users
  end
  
  # GET /users/1
  def show
    display @user
  end
  
  # GET /users/1/new
  def new
    only_provides :html
    @user = User.new
    render
  end
  
  # POST /users
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:confirm] = 'Registration Successful!  You can now login below:'
      redirect url(:home)
    else
      render :new
    end
  end
  
  # GET /users/current/edit
  def edit
    only_provides :html
    render
  end
  
  # PUT /users/current
  def update
    if @user.update_attributes(params[:user])
      redirect url(:users)
    else
      render :edit
    end
  end
  
  # POST /users/current/ping
  def ping
    @user.pinged!
    redirect url(:users)
  end
  
  
  private
  
  def fetch_active_users
    @users = User.all(:active => true, :suspended_at => nil)
  end
  
  def fetch_user
    @user = User[params[:id].to_i]
  end
  
  def fetch_current_user
    @user = current_user
    raise NotFound unless @user
  end
  
end
