
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "indented_io/version"

Gem::Specification.new do |spec|
  spec.name          = "indented_io"
  spec.version       = IndentedIO::VERSION
  spec.authors       = ["Claus Rasmussen"]
  spec.email         = ["claus.l.rasmussen@gmail.com"]

  spec.summary       = %q{Print indented text}
  spec.description   = %q{
                          IndentedIO extends Kernel, IO, and StringIO
                          with an #indent method that returns an IndentedIO
                          object. The IndentedIO object acts as the original
                          object but redefines the output methods #print,
                          #printf, #puts, and #p to print their output
                          indented. Indentations are stacked so that each new
                          indentation adds to the previous indendation
                       }
  spec.homepage      = "https://github.com/clrgit/indented_io"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
