require 'test/unit'
require 'yajp/lexer'

class TestLexer < Test::Unit::TestCase
  data({
    'true literal' => ['true', :TRUE],
    'false  literal' => ['false', :FALSE],
    'null literal' => ['null', :NULL],
    'left brace' => ['{', '{'],
    'right brace' => ['}', '}'],
    'left bracket' => ['[', '['],
    'right bracket' => [']', ']'],
    'comma' => [',', ','],
    'colon' => [':', ':'],
    'simple string literal' => [%Q`"Hello."`, :STRING, 'Hello.'],
    'simple integer literal' => ['123', :NUMBER, 123],
    'simple integer with zero' => ['1230', :NUMBER, 1230],

    'zero'       => ['0', :NUMBER, 0],
    'minus zero' => ['-0', :NUMBER, 0],

    'a digit' => ['5', :NUMBER, 5],
    'one digit with minus' => ['-7', :NUMBER, -7],

    'zero decimal' => ['0.00', :NUMBER, 0.0],
    'decimal less than 1' => ['-0.12', :NUMBER, -0.12],
    'decimal more than 1' => ['3.1401', :NUMBER, 3.1401],
    'decimal with exponent' => ['1.23e1', :NUMBER, 12.3],
    'decimal with -exponent' => ['0.12e-1', :NUMBER, 0.012],
    'decimal with +exponent' => ['7.891e+2', :NUMBER, 789.1],
  })
  test 'one token' do |data|
    lexer = YAJP::Lexer.new(data.first)
    token = lexer.read
    assert_equal data[1], token.kind
    assert_equal data[2], token.value if data.size >= 3
    token = lexer.read
  end
end

