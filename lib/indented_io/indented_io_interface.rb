module IndentedIO
  # IndentedIO interface that provides the #indent method. Used by IO,
  # StringIO, and IndentedIO. It can be included in any class that define a
  # #print method
  module IndentedIOInterface
    # Returns a IndentedIO object that can be used for printing. The IO object
    # will pass-through all method calls except #print, #printf, #puts, and #p
    # to the enclosing object
    #
    # :call-seq:
    #   indent(levels = 1)
    #   indent(levels, string)
    #   indent(levels, string: indent_string, bol: beginning_of_line)
    #   indent(levels, string, bol: beginning_of_line)
    #
    # +levels+:: Number of indentation levels. Default is one level
    # +string+:: The indentation string. Default is the indent string of the
    #            outer level or ::IndentedIO.default_indent if this is the
    #            first level
    # +bol+:: Beginning of line. If true, #indent will begin writing with an
    #         indentation string. If false, it will only indent after the next
    #         newline. Default true
    def indent(levels = 1, string_ = ::IndentedIO.default_indent, string: string_, bol: nil, &block)
      block.nil? || block.arity == 1 or raise ::IndentedIO::Error.new "Wrong number of parameters"
      obj = ::IndentedIO::IndentedIO.send(:new, self, levels, string, bol)
      block_given? ? yield(obj) : obj
    end
  end
end
