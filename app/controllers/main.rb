class Main < Application
  
  def index
    if logged_in?
      redirect url(:users)
    else
      render
    end
  end
  
  def about
    render
  end
  
end
