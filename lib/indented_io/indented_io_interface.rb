module IndentedIO
  # IndentedIO interface that provides the #indent method. It is used by IO,
  # StringIO, and IndentedIO but can be included in any class that define a
  # #print method like this:
  #
  #   require 'indented_io'
  #   class MyIO
  #     include IndentedIO::IndentedIOInterface
  #     def print(*args) ... end
  #   end
  #
  #   my_io = MyIO.new
  #   my_io.print "Not indented\n"
  #   my_io.indent.puts "It works!"
  #
  #   # Not indented
  #   #   It works!
  #
  module IndentedIOInterface
    # Returns a IndentedIO object that can be used for printing. The IO object
    # will pass-through all method to the underlying device except #print,
    # #printf, #puts, and #p
    #
    # +level+ is the number of leves to indent and +string+ is the string used
    # for indentation. The indentation string can also be given as the keyword
    # parameter +:string+. Default is the indent string of the outer level or
    # {::IndentedIO.default_indent} if this is the first level. +:bol+ control the
    # beginning-of-line status: If true, #indent will begin writing with an
    # indentation string as if it was at the beginning of the line. If false,
    # it will only indent after the next newline. Default is true
    #
    # If +level+ is negative, #indent will outdent text instead
    #
    def indent(levels = 1, string_ = ::IndentedIO.default_indent, string: string_, bol: nil, &block)
      block.nil? || block.arity == 1 or raise ::IndentedIO::Error.new "Wrong number of parameters"
      obj = ::IndentedIO::IndentedIO.send(:new, self, levels, string, bol)
      block_given? ? yield(obj) : obj
    end
  end
end
