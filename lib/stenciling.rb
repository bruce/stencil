module Stenciling
  class << self
    
    def included(base)
      base.send(:include, InstanceMethods)
      base.send(:alias_method_chain, :method_missing, :stenciling)
    end
    
  end
  
  module InstanceMethods
    def method_missing_with_stenciling(meth, *args, &block)
      stencil_candidate = "#{meth.to_s.camelize}Stencil".constantize rescue nil
      if stencil_candidate && stencil_candidate.ancestors.include?(Stencil)
        returning stencil_candidate.new(*args, &block) do |stencil|
          stencil.template = self
        end
      else
        method_missing_without_stenciling(meth, *args, &block)
      end
    end
  end
end