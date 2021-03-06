require 'stringio' # Requiered to avoid 'superclass mismatch' errors in other modules
require 'indented_io/indented_io_interface'

# Includes the IndentedIOInterface that define the #indent method
class StringIO
  include IndentedIO::IndentedIOInterface
end
