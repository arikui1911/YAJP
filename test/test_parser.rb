require 'test/unit'
require 'yajp/parser'
require 'yajp/lexer'

module YAJP
  class MockLexer
    def initialize(filename, tokens)
      @filename = filename
      @tokens = tokens.each
    end

    attr_reader :filename

    def read
      @tokens.next
    end
  end
end


class TestParser < Test::Unit::TestCase
  def mock_lexer(*tokens)
    @filename = '*(mock lexer)*'
    YAJP::MockLexer.new(@filename, tokens.map{|x| YAJP::Lexer::Token.new(*x) })
  end

  def assert_json_value(node, lexer)
    assert_equal [:json, [1, 1], @filename, node], YAJP::Parser.new(lexer).parse
  end

  data({
    'number' => [[:number, 123], [:NUMBER, 123]],
    'string' => [[:string, 'Hello'], [:STRING, 'Hello']],
    'true' => [[:true], [:TRUE, true]],

    # 'array' => [[:array, [:number, 1
  })
  test 'parse value' do |data|
    assert_json_value [data[0][0], [1, 1], *data[0].drop(1)], mock_lexer([*data[1], 1, 1], [:EOF, nil, 2, 1])
  end
end

