class Exceptions < Application
  def not_found
    render :format => :html
  end

  def not_acceptable
    render :format => :html
  end
end