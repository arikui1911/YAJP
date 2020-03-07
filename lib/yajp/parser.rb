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
end

