require 'indented_io/indented_io_interface'

module IndentedIO
  # An IO device that writes indented text by reimplementing #write, #print,
  # #printf, #puts, and #p
  #
  # IndentedIO objects forms a chain that acts as a stack. The lowest element
  # in the stack is always a "pure" IO object (eg. $stdout). IndentedIO object
  # are than moved on and off the stack as indentation levels rise or fall
  #
  # Note that #new is private. The only way to create a IndentedIO object is to
  # call #indent on an object that supports it ({Kernel}, {IO}, or {StringIO})
  class IndentedIO
    include IndentedIOInterface

    # @!visibility private
    alias :interface_indent :indent

    # (see IndentedIO::IndentedIOInterface#indent)
    def indent(depth=1, string_ = self.this_indent, string: string_, bol: nil, &block)
      interface_indent(depth, string, bol: bol, &block)
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
    # as Kernel#p. Please note that even though #p is only defined on Kernel it
    # can also be used on any IndentedIO object so you can say '$stderr.p
    # value'. This also deviates from the standard ruby $stderr object that
    # doesn't have a #p method defined
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

    # Make IndentedIO behave like the underlying @device by only searching for
    # methods in the device
    #
    # @!visibility private
    def respond_to?(method, include_all = false)
      [:indent, :depth, :tab, :p].include?(method) || device.respond_to?(method, include_all)
    end

    # Make IndentedIO behave like the underlying @device
    # @!visibility private
    def method_missing(method, *args)
      device.send(method, *args)
    end

    # Depth of this object. #depth is always bigger than zero for IndentedIO
    # objects
    attr_reader :depth

    # Tabulator position for this object. The is the same as the combined
    # length of the indentation levels
    attr_reader :tab

  protected
    # Parent object. This can be an IndentedIO, IO, or StringIO object
    attr_reader :parent

    # Reference to the pure IO object at the bottom of the stack. It is used to
    # write directly to the IO object without having to recurse down the IndentedIO
    # stack
    attr_reader :device

    # First IndentedIO object on the stack. Equal to self if self is the first
    # indentation object. The #initial object is used to store a stack-global
    # bol flag
    attr_reader :initial

    # Indent string for this device
    attr_reader :this_indent

    # The combined indent strings of previous levels plus this device's indent string
    attr_reader :combined_indent

    # True iff at Beginning-Of-Line. Note that #bol is global for the whole
    # indentation stack
    def bol()
      @initial == self ? @bol : @initial.bol # @bol only exists in the #base object
    end

    # Set Beginning-Of-Line to true or false. Note that #bol is global for the
    # whole indentation stack
    def bol=(bol)
      @initial.instance_variable_set(:@bol, bol) # @bol only exists in the #initial object
    end

    # Number of indent levels for this IndentedIO object
    attr_reader :levels

    # Hide new
    private_class_method :new

    # TODO: Move multi-level functionality to ::IndentedIO.indent
    def initialize(parent, levels, this_indent, bol)
      if levels < 0
        parent.is_a?(::IndentedIO::IndentedIO) or raise ::IndentedIO::Error.new "Negative levels argument"
        parent.levels + levels >= 0 or raise ::IndentedIO::Error.new "levels out of range"
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
      @depth = @parent.depth + levels
      @tab = @parent.tab + this_indent.size * @levels
      @this_indent = this_indent
      if @parent.is_a?(::IndentedIO::IndentedIO)
        @device = @parent.device
        @initial = @parent.initial
        @combined_indent = @parent.combined_indent + @this_indent * @levels
        self.bol = bol if !bol.nil?
      else
        @device = parent
        @initial = self
        @combined_indent = @this_indent * @levels
        self.bol = (bol.nil? ? true : bol)
      end
    end
  end
end
