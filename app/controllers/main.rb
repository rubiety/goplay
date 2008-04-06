# == Main Controller
# General main controller implementing miscellanous actions 
# such as the about page and home page / login page.
# 
class Main < Application
  
  # GET /
  def index
    if logged_in?
      redirect url(:users)
    else
      render
    end
  end
  
  # GET /about
  def about
    render
  end
  
end
