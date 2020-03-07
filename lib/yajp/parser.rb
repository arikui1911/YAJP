require_relative './parse.tab'
require 'yajp/lexer'

module YAJP
  class Parser
    def initialize(lexer)
      @lexer = lexer
      @core = ParseCore.new(lexer)
    end

    def parse
      [:json, @lexer.filename, @core.parse]
    end
  end

  class ParseError < RuntimeError
    def initialize(cause_token, msg)
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
      raise ParseError.new(token, "#{@lexer.filename}:#{token.line}:#{token.col}: parse error on #{insp})")
    end
  end
  private_constant :ParseCore
end

