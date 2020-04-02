module YAJP
  # Utility module to deal YAJP options.
  #
  # "YAJP options" means optional keyword parameters of
  # SomeClass#initialize(), SomeClass includes this module.
  #
  module Optionable
    # Binds options to instance variables.
    # 
    # @param [Binding] bind   a binding of #initialize
    # 
    def optionable_init(bind)
      self.class.options.each do |o|
        instance_variable_set "@#{o}", bind.local_variable_get(o)
      end
    end

    def self.included(c)
      c.extend ClassMethods
    end

    module ClassMethods
      # Returns "YAJP options" list.
      #
      # @return [Array<Symbol>] options name list
      # 
      def options
        instance_method(:initialize).parameters.select{|a| a.first == :key }.map(&:last)
      end
    end
  end
end

