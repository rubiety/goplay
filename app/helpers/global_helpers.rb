module Merb
  module GlobalHelpers
    
    # Outputs the error messages block.  
    # The first argument specifies a hash options:  
    # * :on => :products   Also includes AR validation errors for @products  
    # * :clear => true     Clears messages after displaying  
    # * :keep => true      Keeps around messages for next response cycle  
    #  
    def message_block(options = {})  
      out = ""
      
      [:back, :confirm, :error, :info, :warn].each do |type|  
        next if flash[type].nil? or flash[type].empty?  
        flash[type] = [flash[type]] unless flash[type].is_a?(Array)  
        
        out << "<div class=\"container #{type}\"><ul>\n"  
        flash[type].each {|msg| out << "<li>#{h(msg.to_s)}</li>\n"}  
        out << "</ul></div>\n"  
        
        flash[type] = nil if options[:clear]  
        flash.keep[type] if options[:keep]  
      end
      
      if options[:on]
        options[:on] = [options[:on]] unless options[:on].kind_of?(Array)  
        models = options[:on].map {|m| instance_variable_get("@" + m.to_s)}.select {|m| !m.nil?}  
        errors = models.inject([]) {|b,m| b += m.errors.full_messages}  
        
        if errors.size > 0
          out << "<div class=\"container error\"><ul>\n"  
          errors.each {|msg| out << "<li>#{h(msg.to_s)}</li>\n"}  
          out << "</ul></div>\n"  
        end
      end
      
      "<div id=\"message_block\" class=\"flash\">#{out}</div>"
    end
  end
end
