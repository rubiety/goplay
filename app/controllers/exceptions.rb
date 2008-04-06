# == Exceptions Handling Controller
# Implements default handling for common 
# exceptions.
# 
class Exceptions < Application
  def not_found
    render :format => :html
  end
  
  def not_acceptable
    render :format => :html
  end
end
