# == Login Sessions
# Controls login sessions in the now cliche RESTful manner.
# Creating a session is logging in, destroying a session is logging out. 
# Though not a singular resource, this is effectively a "singleton resource" 
# of current.
# 
class Sessions < Application
  
  before :login_required, :only => :destroy
  
  # GET /sessions/new
  # We don't have a dedicated login page, so just direct to home:
  def new
    redirect url(:home)
  end
  
  # POST /sessions
  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      current_user.enter!
      
      redirect_back_or_default('/')
    else
      flash[:error] = 'Invalid Login'
      redirect url(:home)
    end
  end
  
  # DELETE /sessions/current
  def destroy
    current_user.leave!
    
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    
    flash[:confirm] = 'Successfully Logged Out'
    redirect_back_or_default('/')
  end
  
end