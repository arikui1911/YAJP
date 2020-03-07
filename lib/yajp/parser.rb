require_relative './parse.tab'
require 'yajp/lexer'

module YAJP
  class Parser
    def parse(src, filename: nil, initial_lineno: 1)
      @lexer = Lexer.new(src, filename: filename, initial_lineno: initial_lineno)
      [:json, filename, @core.do_parse()]
    end

    private

    def next_token
      token = @lexer.read
      return [false, nil] if token.kind == :EOF
      [token.kind, token]
    end
  end
end

