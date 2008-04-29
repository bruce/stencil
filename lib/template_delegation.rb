module TemplateDelegation
  
  def self.included(base)
    base.send(:attr_accessor, :template)
    base.send(:delegate, :to_s, :to => :draw)
    base.send(:include, DelegationMethods)
    base.send(:include, OutputMethods)
  end
  
  module DelegationMethods
  
    def template_delegate(obj)
      returning obj do
        (class << obj; self; end).send(:include, TemplateDelegation)
        obj.template = self.template
        yield obj if block_given?
      end
    end
  
    # Forward all missing methods to +template+,
    # and write method directly to +template+ for future
    # invocations
    def method_missing(meth, *args, &block) #:nodoc:
      returning template.__send__(meth, *args, &block) do
        self.class.class_eval %{delegate :#{meth}, :to => :template}
      end
    end
    
  end
  
  module OutputMethods
    
    def erb(text, &b)
      ERB.new(text).result(binding)
    end
    
  end
  
end