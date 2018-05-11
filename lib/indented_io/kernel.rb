require 'indented_io/indented_io_interface'

module Kernel
  # Like {IndentedIO::IndentedIOInterface#indent} except the underlying device is
  # not the receiver (Kernel) but $stdout. Kernel#indent also allows a block without
  # and argument. In that case it manipulates $stdout to print indented:
  #
  #   puts "Not indented
  #   indent {
  #     puts "Indented"
  #     indent {
  #       puts "Even more indented"
  #     }
  #   }
  #
  #   # Not indented
  #   #   Indented
  #   #     Even more indented
  #
  def indent(levels = 1, string_ = IndentedIO.default_indent, string: string_, bol: nil, &block)
    block.nil? || block.arity <= 1 or raise IndentedIO::Error.new "Wrong number of parameters"
    obj = IndentedIO::IndentedIO.send(:new, $stdout, levels, string, bol)
    if block_given?
      if block.arity == 1
        r = yield obj
      elsif block.arity == 0
        saved_stdout = $stdout
        begin
          $stdout = obj
          r = yield
        ensure
          $stdout = saved_stdout
        end
      end
    else
      r = obj
    end
    r
  end
end

