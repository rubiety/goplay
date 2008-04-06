require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies")

# == Application Base Controller
# Base application controller from which all other merb controllers extend.
# Includes any common functionality between all controllers, such as the 
# authentication system.
# 
class Application < Merb::Controller
  include AuthenticatedSystem::Controller
  
end