require 'yajp/optionable'

module YAJP
  # Lexer lexical-analize JSON source and returns token object
  # like a kind of stream.
  #
  # Lexer solves analizing for 'not-container value'
  # (it means JSON values excluded object and array).
  #
  class Lexer
    include Optionable

    # Generate a lexer instance.
    # 
    # @param [#each_line] src             String, IO and others contains JSON source
    # @param [String]     filename        a filename of src used for error message, for example
    # @param [Integer]    initial_lineno  lexer count line number of src from this value
    # @param [boolean]    comment         Allow comment syntax or not
    #
    # @return [Lexer] a lexer instance
    #
    def initialize(src, filename = nil, initial_lineno = 1, comment: false)
      optionable_init binding()
      @src = src
      @file = filename
      @line = initial_lineno
      @col = 1
      @fib = Fiber.new(&method(:lex))
    end

    def filename
      @file
    end

    # Returns next token.
    # 
    # @return [Token] token object
    # @return [nil]   no more token might be
    #
    def read
      @fib.resume
    end

    private

    def emit_raw(token)
      Fiber.yield token
    end

    def emit(kind, value)
      emit_raw new_token(kind, value)
    end

    Token = Struct.new(:kind, :value, :line, :col)

    def new_token(kind, value, line = @line, col = @col)
      Token.new(kind, value, line, col)
    end

    def lex
      @state = :initial
      @src.each_line do |line|
        rest = line
        until rest.empty?
          rest = send("lex_#{@state}", rest)
          @col = line.size - rest.size
        end
        @line += 1
      end
      emit :EOF, nil
    end

    def lex_initial(src)
      line_comment_re      = @comment ? /\A\/\// : /(?!)/
      block_comment_beg_re = @comment ? /\A\/\*/ : /(?!)/
      case src
      in /\A[\s\n]+/
        # do nothing
      in ^line_comment_re
        return ''
      in ^block_comment_beg_re
        @state = :comment
      in /\A"/
        @string = new_token(:STRING, String.new)
        @state = :string
      in /\A-?[1-9]\d*\.\d+([eE][+-]?\d+)?/ | /\A-?0\.\d+([eE][+-]?\d+)?/
        emit :NUMBER, Float($&)
      in /\A-?[1-9]\d*/ | /\A-?0/
        emit :NUMBER, Integer($&)
      in /\Atrue/
        emit :TRUE, true
      in /\Afalse/
        emit :FALSE, false
      in /\Anull/
        emit :NULL, nil
      in /\A[_a-zA-Z][_a-zA-Z\d]*/
        emit :SYMBOL, $&
      in /\A./
        emit $&, $&
      end
      $'
    end

    def lex_comment(src)
      case src
      in /\A\*\//
        @state = :initial
      in /\A[\s\n]+/ | /\A./
        # do nothing
      end
      $'
    end

    ESC = {
      '"' => '"',
      '\\' => '\\',
      '/' => '/',
      'b' => "\b",
      'f' => "\f",
      'n' => "\n",
      'r' => "\r",
      't' => "\t",
    }
    private_constant :ESC

    def lex_string(src)
      case src
      in /\A"/
        @string.value.freeze
        emit_raw @string
        @state = :initial
      in /\A\\u([\da-fA-F]{4})/
        @string.value << Integer("0x#{$1}").chr('UTF-8')
      in /\A\\(["\\\/bfnrt])/
        @string.value << ESC.fetch($1)
      in /\A[\s\n]+/ | /\A./
        @string.value << $&
      end
      $'
    end
  end
end

