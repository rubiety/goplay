class Sessions < Application
  
  # GET /sessions/new
  def new
    render
  end
  
  # POST /sessions
  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      
      current_user.enter
      
      redirect_back_or_default('/')
    else
      flash[:error] = 'Invalid Login'
      redirect url(:home)
    end
  end
  
  # DELETE /sessions/mine
  def destroy
    current_user.leave
    
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    
    flash[:confirm] = 'Successfully Logged Out'
    redirect_back_or_default('/')
  end
  
end