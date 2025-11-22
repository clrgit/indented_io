require 'stringio'
require_relative 'stringio' # Required to avoid 'superclass mismatch' errors in other modules
require_relative 'indented_io_interface'

# Includes the IndentedIOInterface that define the #indent method
class StringIO
  include IndentedIO::IndentedIOInterface
end
