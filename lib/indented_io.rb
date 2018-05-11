
require 'indented_io/version'
require 'indented_io/error'
require 'indented_io/indented_io'
require 'indented_io/indented_io_interface'
require 'indented_io/kernel'
require 'indented_io/io'
require 'indented_io/stringio'

# IndentedIO module

module IndentedIO
  # Returns default indentation. Two spaces is the default but it can be set by
  # #default_indent
  def self.default_indent() @DEFAULT_INDENT end

  # Sets default indentation
  def self.default_indent=(indent) @DEFAULT_INDENT = indent end

private
  @DEFAULT_INDENT = "  "
end

