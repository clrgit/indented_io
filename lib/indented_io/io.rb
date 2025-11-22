require_relative 'indented_io_interface'

# Includes the IndentedIOInterface that define the #indent method
class IO
  include IndentedIO::IndentedIOInterface
end

