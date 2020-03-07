module YAJP
  class Compiler
    def compile(ast)
      case ast
      in [:json, filename, element]
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
      members.each_with_object({}){|(k, v), h| h[k] = compile(v) }
    end

    def compile_array(elements)
      elements.map{|e| compile e }
    end
  end
end

