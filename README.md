# IndentedIO

Print indented text

`IndentedIO` extends `Kernel`, `IO`, and `StringIO` with an `#indent` method
that returns an `IndentedIO` object. The `IndentedIO` object acts as the
original object but redefines the output methods `#print`, `#printf`, `#puts`,
and `#p` to print their output indented.  Indentations are stacked so that each
new indentation adds to the previous indendation

## Usage

```ruby
require 'indented_io'

puts "Not indented"
indent { puts "Indented one level" }
indent(2, "* ").puts "Indented two levels"
```

outputs

```ruby
Not indented
  Indented one level
* * Indented two levels
```

#### `#indent`

`#indent` without a block returns an `IndentedIO` object that acts as the
receiver but redefine `#print`, `#printf`, `#puts`, and `#p` to print indented
If given a block, the block will be called with the IndentedIO object as
argument:

```ruby
$stdout.puts "Not indented"
$stdout.indent.puts "Indented"
$stdout.indent { |f| f.puts "Indented" }

# Not indented
#   Indented
#   Indented
```
(please note that when `Kernel` is the receiver, the returned object will
act as the `$stdout` object and not the `Kernel` object)

`#indent` can take up to two positional arguments: `level`, that is the number
of levels to indent (default 1), and the indent string that defaults to the
indent string of the previous level or `IndentedIO.default_string` if at the
first level. It is also possible to specify the indentation string using the
symbolic argument `:string`. If level is negative, the text will be outdented
instead:

```ruby
$stdout.puts "Not indented"
$stdout.indent(2, "> ") { |f|
  f.indent(string: "* ").puts "Indented three levels"
  f.indent(-1).puts "Indented one level"
}

# Not indented
# > > * Indented three levels
# > Indented one level
```
When text is outdented, the indentation string defaults to the previous level's
indentation string - not the parent's

#### `Kernel#indent {}`

If given a block without an argument, `Kernel#indent` manipulates `$stdout` so
that `Kernel#print`, `Kernel#printf`, `Kernel#puts`, and `Kernel#p` will output
indented within that block:

```ruby
puts "Not indented"
indent {
  puts "Indented one level"
  indent {
    puts "Indented two levels"
  }
  puts "Indented one level"
}
puts "Not indented"

# Not indented
#   Indented one level
#     Indented two levels
#   Indented one level
# Not indented
```
Because this manipulates `$stdout`, the indentation carries through to methods
that doesn't even know about `IndentedIO`:

```ruby
def legacy(phrase)
  puts phrase
end

legacy("Not indented")
indent { legacy("Indented" }

# Not indented
#   Indented
```
This is probably the style that'll be used most of the time. It is of course
still possible use `Kernel#indent` with a block argument if needed

#### bol - Beginning-Of-Line argument

`#indent` takes a symbolic `:bol` argument (`true` or `false`, default `true`) 
that specify if the output device is at the beginning of a line and that printing
should start with an indentation string:

```ruby
indent(1, bol: true).puts "Indented"
indent(1, bol: false).puts "Not indented\nIndented"

#   Indented
# Not indented
#   Indented
```

## Constants

The default indentation string is defined in `IndentedIO`:

```ruby
IndentedIO.default_indent = ">> "
indent.puts "Indented by #{IndentedIO.default_indent.inspect}"

# >> Indented by ">> "
```

The default at start-up is two spaces. It should normally be set only once
at the start of the program. Use the indent string argument to `#indent` 
to get a different indentation for a part of the program

## Exceptions

In case of errors an `IndentedIO::Error` exception is raised

## Add support for other classes

You can add support for your own IO objects by including
`IndentedIO::IndentedIOInterface` in your class.  All that is required is that
the class define a `#print` method with the same semantics as the system
`#print`

```ruby
require 'indented_io'
class MyIO
  include IndentedIO::IndentedIOInterface
  def print(*args) ... end
end

my_io = MyIO.new
my_io.indent.puts "It works!"
```

## Implementation & performance

`IndentedIO` is intrusive because it extends the standard classes `Kernel`,
`IO`, and `StringIO` with the `#indent` method. In addition, `Kernel#indent`
with a block without parameters manipulates `$stdout`, replacing it with an
`IndentedIO` object for the duration of the block

The implementation carries no overhead if it is not used but the core indentation
mechanism processes characters one-by-one which is slow compared to what could
be achived with a native C implementation


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'indented_io'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install indented_io

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/clrgit/indented_io.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
