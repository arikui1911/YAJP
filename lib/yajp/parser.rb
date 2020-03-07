require_relative './parse.tab'
require 'yajp/lexer'

module YAJP
  # Parser parses lexer-token-stream and returns AST.
  #
  # AST are represented by Array: [node_type_symbol, [line, col], attrs...]
  #
  class Parser
    def initialize(lexer)
      @lexer = lexer
      @core = ParseCore.new(lexer)
    end

    # Run parser.
    #
    # @return [Array] AST (Abstract Syntax Tree) of JSON
    #
    # @raise [ParseError] JSON might contain syntax error
    #
    def parse
      [:json, [1, 1], @lexer.filename, @core.parse]
    end
  end

  class ParseError < RuntimeError
    def initialize(msg, cause_token = nil)
      super msg
      @cause_token = cause_token
    end

    attr_reader :cause_token
  end

  class ParseCore
    def initialize(lexer)
      @lexer = lexer
    end

    def parse
      do_parse
    end

    private

    def next_token
      token = @lexer.read
      return [false, nil] if token.kind == :EOF
      [token.kind, token]
    end

    def pos(token)
      [token.line, token.col]
    end

    def on_error(id, token, stack)
      insp = token.value.inspect
      insp = "#{insp}(#{token.kind})" unless token.kind == token.value
      raise ParseError.new("#{@lexer.filename}:#{token.line}:#{token.col}: parse error on #{insp})", token)
    end

    def empty_input!
      raise ParseError.new("empty input")
    end
  end
  private_constant :ParseCore
end

