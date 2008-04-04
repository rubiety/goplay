require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies")

class Application < Merb::Controller
  include AuthenticatedSystem::Controller
  
end