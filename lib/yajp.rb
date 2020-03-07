require 'yajp/lexer'
require 'yajp/parser'
require 'yajp/compiler'
require 'pathname'

module YAJP
  def self.parse_string(src, **options)
    raise ArgumentError, "#{src} is not compatible to String" unless src.respond_to?(:to_str)
    ast = do_parse(src.to_str, Object.instance_method(:inspect).bind(src).call)
    do_compile ast, options
  end

  def self.parse_file(path, **options)
    raise ArgumentError, "#{path} is not compatible to file path" unless path.respond_to?(:to_path)
    path = path.to_path
    ast = File.open(path){|f| do_parse f, path }
    do_compile ast, options
  end

  def self.do_parse(src, fname)
    lexer = Lexer.new(src, filename: fname)
    parser = Parser.new(lexer)
    parser.parse
  end
  private_class_method :do_parse

  def self.do_compile(ast, options)
    compiler = Compiler.new{|c|
      options.each do |k, v|
        setter = "#{k}=".intern
        raise ArgumentError, "YAJP invalid option: #{k}" unless c.respond_to?(setter)
        c.__send__ setter, v
      end
    }
    compiler.compile ast
  end
  private_class_method :do_compile
end

