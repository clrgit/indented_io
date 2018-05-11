require 'indented_io/indented_io_interface'

# :nodoc:
module Kernel
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

