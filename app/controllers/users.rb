class Users < Application
  provides :xml, :yaml, :js
  
  before :login_required, :exclude => [:new, :create]
  before :fetch_active_users, :only => [:index]
  before :fetch_user, :exclude => [:index, :new, :create]
  
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
  
  # GET /users/1/edit
  def edit
    only_provides :html
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
  
  # PUT /users/1
  def update
    if @user.update_attributes(params[:user])
      redirect url(:user, @user)
    else
      raise BadRequest
    end
  end
  
  # DELETE /users/1
  def destroy
    if @user.destroy!
      redirect url(:user)
    else
      raise BadRequest
    end
  end
  
  
  private
  
  def fetch_active_users
    @users = User.all(:active => true)
  end
  
  def fetch_user
    @user = current_user
    raise NotFound unless @user
  end
  
end
