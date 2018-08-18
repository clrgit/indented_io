require 'indented_io/indented_io_interface'

module IndentedIO
  # An IO device that writes indented text
  #
  # IndentedIO objects forms a chain that acts as a stack. The lowest element
  # in the stack is always a "pure" IO object (eg. $stdout) and as indentation
  # levels rise or fall IndentedIO objects are moved on and off the stack
  #
  # Note that #new is private. The only way to create a IndentedIO object is to
  # call #indent on an object that supports it ({Kernel}, {IO}, or {StringIO})
  class IndentedIO
    include IndentedIOInterface

    # @!visibility private 
    alias :interface_indent :indent

    # (see IndentedIO::IndentedIOInterface#indent)
    def indent(levels=1, string_ = self.this_indent, string: string_, bol: nil, &block)
      interface_indent(levels, string, bol: bol, &block)
    end

    # Indent and print args to the underlying device. #write has the same semantic
    # as IO#write
    def write(*args)
      str = args.join
      return if str.empty?
      s = (bol && str[0] != "\n" ? @combined_indent : "") + str.gsub(/\n([^\n])/m, "\n#{@combined_indent}\\1")
      self.bol = (s[-1] == "\n")
      @device.write(s)
    end

    # Indent and print args to the underlying device. #print has the same semantic
    # as Kernel#print
    def print(*args)
      return nil if args.empty?
      write(args.join($, || ''))
      write($\) if $\
      nil
    end

    # Indent and print args to the underlying device. #printf has the same semantic
    # as Kernel#printf
    def printf(format, *args)
      write format % args
    end

    # Indent and print args to the underlying device. #puts has the same semantic
    # as Kernel#puts
    def puts(*args)
      write args.join("\n"), "\n"
      nil
    end

    # Indent and print args to the underlying device. #p has the same semantic
    # as Kernel#p. Please note that #p is only defined on Kernel in the Ruby core
    # library but can be used on any IndentedIO object
    def p(*args)
      if bol
        args.each { |arg| write(arg.inspect, "\n") }
      else
        @device.write(args.first.inspect, "\n")
        bol = true
        args[1..-1].each { |arg| write(arg.inspect, "\n") }
      end
      args.size == 1 ? args.first : args
    end

    # Make IndentedIO behave like the underlying @device
    # @!visibility private 
    def respond_to?(method)
      [:indent, :level, :print, :printf, :puts, :p].include?(method) || device.respond_to?(method)
    end

    # Make IndentedIO behave like the underlying @device
    # @!visibility private 
    def method_missing(method, *args)
      device.send(method, *args)
    end

  protected
    # Reference to the pure IO object at the bottom of the stack. It is used to
    # write directly to the IO object without having to recurse down the IndentedIO
    # stack
    attr_reader :device

    # First IndentedIO object on the stack. Equal to self if self is the first
    # indentation object. The #base object is used to keep track of #bol for
    # the whole stack of IndentedIO objects
    attr_reader :base

    # Parent IndentedIO or IO object
    attr_reader :parent

    # Number of indent levels
    attr_reader :levels

    # Indent string for this device
    attr_reader :this_indent

    # The combined indent strings of previous levels plus this device's indent string
    attr_reader :combined_indent

    # True iff at Beginning-Of-Line
    def bol()
      @base == self ? @bol : @base.bol # @bol only exists in the #base object
    end

    # Set Beginning-Of-Line to true or false
    def bol=(bol)
      @base.instance_variable_set(:@bol, bol) # @bol only exists in the #base object
    end

    # Current level
    def level
      @level ||= @levels + (parent.is_a?(::IndentedIO::IndentedIO) ? parent.level : 0)
    end

    # Hide new
    private_class_method :new

    def initialize(parent, levels, this_indent, bol)
      if levels < 0
        parent.is_a?(::IndentedIO::IndentedIO) or raise IndentedIO::Error.new "Negative levels argument"
        parent.level + levels >= 0 or raise IndentedIO::Error.new "levels out of range"
        sibling = parent
        while parent.is_a?(::IndentedIO::IndentedIO) && levels < 0
          levels += parent.levels
          sibling = parent
          parent = parent.parent
        end
        this_indent ||= sibling.indent
      end
      @parent = parent
      @levels = levels
      @this_indent = this_indent
      if @parent.is_a?(::IndentedIO::IndentedIO)
        @device = @parent.device
        @base = @parent.base
        @combined_indent = @parent.combined_indent + @this_indent * @levels
        self.bol = bol if !bol.nil?
      else
        @device = parent
        @base = self
        @combined_indent = @this_indent * @levels
        self.bol = (bol.nil? ? true : bol)
      end
    end
  end
end
