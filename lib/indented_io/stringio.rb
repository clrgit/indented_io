require 'indented_io/indented_io_interface'

# :nodoc:
class StringIO
  include IndentedIO::IndentedIOInterface
end
