require 'indented_io/indented_io_interface'

module IndentedIO
  # An IO device that writes indented text
  #
  # IndentedIO objects forms a chain that acts as a stack. The lowest element
  # in the stack is always a "pure" IO object (eg. $stdout) and as indentation
  # levels rise or fall IndentedIO objects are moved on and off the stack
  #
  # Note that #new is private. The only way to create a IndentedIO object is to
  # call #indent on a object that supports it
  class IndentedIO
    include IndentedIOInterface

    # :nodoc:
    alias :interface_indent :indent
    # :startdoc:

    # Return a IndentedIO object
    #
    # See IndentedIO::IndentedIOInterface#indent for documentation
    def indent(levels=1, string_ = self.this_indent, string: string_, bol: nil, &block)
      interface_indent(levels, string, bol: bol, &block)
    end

    # Indent and print args to the underlying device. #print has the same semantic
    # as Kernel#print
    def print(*args)
      if bol
        @device.print @combined_indent
        self.bol = false
      end
      args.join.each_char { |c|
        if c == "\n"
          self.bol = true
        elsif bol
          @device.print @combined_indent
          self.bol = false
        end
        @device.print c
      }
      nil
    end

    # Indent and print args to the underlying device. #printf has the same semantic
    # as Kernel#printf
    def printf(format, *args)
      print format % args
    end

    # Indent and print args to the underlying device. #puts has the same semantic
    # as Kernel#puts
    def puts(*args)
      args.each { |arg| print(arg, "\n") }
      nil
    end

    # Indent and print args to the underlying device. #p has the same semantic
    # as Kernel#p. Please note that #p is usually not defined on other classes
    # then Kernel but can be used on any IndentedIO object
    def p(*args)
      if bol
        args.each { |arg| print(arg.inspect, "\n") }
      else
        @device.print args.first.inspect, "\n"
        bol = true
        args[1..-1].each { |arg| print(arg.inspect, "\n") }
      end
      args.size == 1 ? args.first : args
    end

    # :stopdoc:

    # Make IndentedIO behave like the underlying @device
    def respond_to?(method)
      [:indent, :level, :print, :puts, :p].include?(method) || device.respond_to?(method)
    end

    # Make IndentedIO behave like the underlying @device
    def method_missing(method, *args)
      device.send(method, *args)
    end

  protected
    # Reference to the pure IO object at the bottom of the stack. It is used to
    # write directly to the IO object without having to recurse down the IndentedIO
    # stack
    attr_reader :device

    # First IndentedIO object on the stack. Equal to self if self is the first
    # indentation object. #base is used to keep track of #bol for the whole
    # stack of IndentedIO objects
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

  public
    def dump
      $stderr.puts "#{self.class} [#{self.object_id}]"
      $stderr.puts "  device: #{device.class} [#{device.object_id}]"
      $stderr.puts "  base  : #{base.class} [#{base.object_id}]"
      $stderr.puts "  parent: #{parent.class} [#{parent.object_id}]"
      $stderr.puts "  levels: #{levels}"
      $stderr.puts "  this_indent: #{this_indent.inspect}"
      $stderr.puts "  combined_indent: #{combined_indent.inspect}"
      $stderr.puts "  bol: #{bol}"
    end
  end
end
