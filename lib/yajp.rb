require 'yajp/lexer'
require 'yajp/parser'
require 'yajp/compiler'
require 'pathname'

module YAJP
  def self.parse_string(src, symbolize_keys: false)
    raise ArgumentError, "#{src} is not compatible to String" unless src.respond_to?(:to_str)
    insp = Object.instance_method(:inspect).bind(src).call
    src = src.to_str
    lexer = Lexer.new(src, filename: insp)
    parser = Parser.new(lexer)
    ast = parser.parse
    compiler = Compiler.new{|c|
      c.symbolize_keys = symbolize_keys
    }
    compiler.compile ast
  end

  def self.parse_file(path, symbolize_keys: false)
    raise ArgumentError, "#{path} is not compatible to file path" unless path.respond_to?(:to_path)
    path = path.to_path
    ast = File.open(path){|f|
      lexer = Lexer.new(f, filename: path)
      parser = Parser.new(lexer)
      parser.parse
    }
    compiler = Compiler.new{|c|
      c.symbolize_keys = symbolize_keys
    }
    compiler.compile ast
  end
end

