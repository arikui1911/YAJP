require 'yajp/optionable'
require 'yajp/lexer'

module YAJP
  class Parser
    include Optionable

    def initialize(lexer, trailing_comma: false)
      optionable_init binding()
      @lexer = lexer
      @buf = []
    end

    def parse
      parse_json
    end

    private

    def read
      @buf.empty? ? @lexer.read : @buf.pop
    end

    def unread(token)
      @buf.push token
      nil
    end

    def peek
      read().tap{|t| unread t }
    end

    def pos(token)
      [token.line, token.col]
    end

    def inspect_token(t)
      return t.value.inspect if t.kind == t.value
      "#{t.value.inspect}(#{t.kind})"
    end

    def parse_error(t, msg)
      raise ParseError.new("#{@lexer.filename}:#{t.line}:#{t.col}: #{msg}", t)
    end

    def expect(kind)
      t = read()
      parse_error(t, "expect #{kind} but #{inspect_token t}") unless kind == t.kind
      t
    end

    def unexpected(t)
      parse_error t, "unexpected #{inspect_token t}"
    end

    def parse_json
      t = read()
      raise ParseError.new("empty input") if t.kind == :EOF
      unread t
      [:json, [1, 1], @lexer.filename, parse_element()]
    end

    def parse_element
      t = read()
      case t.kind
      when '{'
        unread t
        parse_object
      when '['
        unread t
        parse_array
      when :STRING
        [:string, pos(t), t.value]
      when :NUMBER
        [:number, pos(t), t.value]
      when :TRUE
        [:true, pos(t)]
      when :FALSE
        [:false, pos(t)]
      when :NULL
        [:null, pos(t)]
      else
        unexpected t
      end
    end

    def parse_object
      beg = expect('{')
      t = read()
      case t.kind
      when '}'
        [:object, pos(beg), []]
      when :STRING
        unread t
        members = parse_members()
        expect '}'
        [:object, pos(beg), members]
      else
        unexpected t
      end
    end

    def parse_members
      members = [parse_member()]
      loop do
        t = read()
        unless t.kind == ','
          unread t
          break
        end
        break if @trailing_comma && peek().kind == '}'
        members << parse_member()
      end
      members
    end

    def parse_member
      k = expect(:STRING)
      expect ':'
      [k.value, parse_element()]
    end

    def parse_array
      beg = expect('[')
      t = read()
      return [:array, pos(beg), []] if t.kind == ']'
      unread t
      elements = parse_elements()
      expect ']'
      [:array, pos(beg), elements]
    end

    def parse_elements
      elements = [parse_element()]
      loop do
        t = read()
        unless t.kind == ','
          unread t
          break
        end
        break if @trailing_comma && peek().kind == ']'
        elements << parse_element()
      end
      elements
    end
  end

  class ParseError < RuntimeError
    def initialize(msg, cause_token = nil)
      super msg
      @cause_token = cause_token
    end

    attr_reader :cause_token
  end
end
