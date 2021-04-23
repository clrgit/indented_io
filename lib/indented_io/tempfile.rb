require 'indented_io/indented_io_interface'

require "tempfile"

# Includes the IndentedIOInterface that define the #indent method
#
# Note that Tempfile used to be a (kind of) IO but that changed in ruby-2.7.
# The problem is that we now have to require both StringIO and Tempfile and
# possible other classes to inject the #indent method instead of just doing it
# once in the IO class itself. TODO: Find a better solution - probably by
# implementing a check in Kernel
class Tempfile
  include IndentedIO::IndentedIOInterface
end
