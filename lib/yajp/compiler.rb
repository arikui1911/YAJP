module YAJP
  # Compiler compiles JSON AST to Ruby objects.
  class Compiler
    def initialize
      yield self if block_given?
    end

    attr_accessor :symbolize_keys

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
        k = k.intern if symbolize_keys
        h[k] = compile(v)
      }
    end

    def compile_array(elements)
      elements.map{|e| compile e }
    end
  end
end

