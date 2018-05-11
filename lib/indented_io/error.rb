
module IndentedIO
  # Error class derived from RuntimeError. To rescue errors from IndentedIO do
  #
  #   begin
  #     # do_some_stuff
  #   rescue IndentedIO::Error => ex
  #     # handle_error
  #   end
  #
  class Error < RuntimeError; end
end

