
module IndentedIO
  # Error class. To rescue errors form IndentedIO do
  #
  #   begin
  #     do_some_stuff()
  #   rescue IndentedIO::Error => ex
  #     handle_error()
  #   end
  #
  class Error < RuntimeError; end
end

