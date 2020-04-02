require 'yajp/optionable'

module YAJP
  # Compiler compiles JSON AST to Ruby objects.
  class Compiler
    include Optionable

    # Generate a compiler instance.
    #
    # @param [boolean] symbolize_keys   Represents object keys by Symbol
    #
    # @return [Compiler] a compiler instance
    #
    def initialize(symbolize_keys: false)
      optionable_init binding()
    end

    # Run compiler.
    #
    # @param [Array] ast JSON AST
    #
    # @return [Object] value from JSON
    #
    def compile(ast)
      case ast
      in [:json, _, filename, element]
        compile(element)
      in [:object, [line, col], members]
        compile_object members
      in [:array, [line, col], elements]
        compile_array elements
      in [:number, [line, col], value]
        value
      in [:string, [line, col], value]
        value
      in [:true, [line, col]]
        true
      in [:false, [line, col]]
        false
      in [:null, [line, col]]
        nil
      end
    end

    private

    def compile_object(members)
      members.each_with_object({}){|(k, v), h|
        k = k.intern if @symbolize_keys
        h[k] = compile(v)
      }
    end

    def compile_array(elements)
      elements.map{|e| compile e }
    end
  end
end

