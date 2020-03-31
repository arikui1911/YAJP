module YAJP
  module Optionable
    def optionable_init(bind)
      self.class.options.each do |o|
        instance_variable_set "@#{o}", bind.local_variable_get(o)
      end
    end

    def self.included(c)
      c.extend ClassMethods
    end

    module ClassMethods
      def options
        instance_method(:initialize).parameters.select{|a| a.first == :key }.map(&:last)
      end
    end
  end
end

