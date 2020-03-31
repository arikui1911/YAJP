require 'yajp/lexer'
require 'yajp/parser'
require 'yajp/compiler'
require 'pathname'

# YAJP is "Yet Another JSON Parser".
#
# YAJP is written in order to practice using pattern matching,
# so it is not considered to be a practical library.
#
module YAJP
  # Parse string which represent JSON source code.
  #
  # @param [String] src JSON source string
  # 
  # @return [Object] value from JSON
  #
  # @raise [ParseError] JSON might contain syntax error
  #
  def self.parse_string(src, **raw_options)
    raise ArgumentError, "#{src} is not compatible to String" unless src.respond_to?(:to_str)
    options = destructure_options(raw_options, Lexer, Parser, Compiler)
    ast = do_parse(src.to_str, Object.instance_method(:inspect).bind(src).call, options[Lexer], options[Parser])
    do_compile ast, options[Compiler]
  end

  # Parse JSON file.
  #
  # @param [String] path file path for JSON file
  # 
  # @return [Object] value from JSON
  #
  # @raise [ParseError] JSON might contain syntax error
  #
  def self.parse_file(path, **raw_options)
    raise ArgumentError, "#{path} is not compatible to file path" unless path.respond_to?(:to_path)
    options = destructure_options(raw_options, Lexer, Parser, Compiler)
    path = path.to_path
    ast = File.open(path){|f| do_parse f, path, options[Lexer], options[Parser] }
    do_compile ast, options[Compiler]
  end

  def self.do_parse(src, fname, lexer_options, parser_options)
    lexer = Lexer.new(src, fname, **lexer_options)
    parser = Parser.new(lexer, **parser_options)
    parser.parse
  end
  private_class_method :do_parse

  def self.do_compile(ast, options)
    Compiler.new(**options).compile ast
  end
  private_class_method :do_compile

  def self.destructure_options(options, *optionables)
    destructureds = {}
    valid_options = {}
    optionables.each do |c|
      h = destructureds[c] = {}
      c.options.each do |o|
        raise ArgumentError, "duplicate option: #{o}" if valid_options[o]
        valid_options[o] = h
      end
    end

    options.each do |k, v|
      valid_options.fetch(k){ raise ArgumentError, "invalid option: #{k}" }.store(k, v)
    end
    destructureds
  end
  private_class_method :destructure_options
end

