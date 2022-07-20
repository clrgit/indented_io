require_relative 'lib/indented_io/version'

Gem::Specification.new do |spec|
  spec.name          = "indented_io"
  spec.version       = IndentedIO::VERSION
  spec.authors       = ["Claus Rasmussen"]
  spec.email         = ["claus.l.rasmussen@gmail.com"]

  spec.summary       = %q{Print indented text}
  spec.description   = %q{
                          IndentedIO extends Kernel, IO, and StringIO with an
                          #indent method that redefines #print, printf, #puts,
                          and #p to print their output indented. Indentations 
                          are stacked so that each new indentation adds to the
                          previous indendation
                       }
  spec.homepage      = "https://github.com/clrgit/indented_io"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
