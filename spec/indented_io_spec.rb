require 'support/indent_method'
require 'support/output_methods'

describe IndentedIO::IndentedIO do
  let(:dev) { StringIO.new } # Underlying IO device
  let(:out) { dev.indent(1, "  ") } # Indented 1 level
  def res() r = dev.string; dev.string = ""; r end # Read and reset dev's result

  it 'forwards method to the underlying device' do
    string_io = dev.indent
    io_io = $stdout.indent
    # kernel_io = Kernel.indent - when using Kernel we really use $stdout 
    expect(string_io.respond_to?(:string)).to eq(true)
    expect(io_io.respond_to?(:close)).to eq(true)
    # expect(kernel_io.respond_to?(:system)).to eq(true)
  end

  it 'outputs to an underlying IO object' do
    dev.indent(1, "  ").puts "Hello"
    expect(res).to eq("  Hello\n")
  end

  context 'when initialized with an IO object' do
    it 'sets the indendation' do
      dev.indent(1, ">>").print "Hello"
      expect(res).to eq(">>Hello")
    end
    it "doesn't allow negative levels" do
      expect { dev.indent(-1, "") }.to raise_error(Error)
    end
  end

  context "when initialized with an IndentedIO object" do
    it 'appends the indentation to the indentation of the outer object' do
      out = dev.indent(1, ">>")
      out.indent(1, "<<").print "*"
      expect(res).to eq(">><<*")
    end
  end

  context 'when initialized with level >= 0' do
    it 'prepends lines with this number of concatenated indentations strings' do
      dev.indent(2, "  ").print "*"
      expect(res).to eq("    *")
    end
  end

  context 'when initialized with level < 0' do
    it 'outdents this number of levels' do
      out = dev.indent(2, '>')
      out.puts "Hello"
      out.indent(-1).print 'World'
      expect(res).to eq(">>Hello\n>World")

      out = dev.indent(2, '>')
      out.puts "Hello"
      out.indent(-2).print 'World'
      expect(res).to eq(">>Hello\nWorld")
    end

    it 'uses sibling indent for defaults' do
      out = dev.indent(1, '>')
      out.indent(-1).indent.print "Hello"
      expect(res).to eq(">Hello")
    end

    it 'raises if called on a device' do
      expect { $stdout.indent(-1) }.to raise_error(Error)
    end

    it 'raises if called with self.level - levels < 0' do
      out = dev.indent
      expect { out.indent(-2) }.to raise_error(Error)
    end
  end

  context "when initialized with an indentation string" do
    it 'uses the indentation string' do
      dev.indent(1, ">>").print "*"
      expect(res).to eq(">>*")
    end
  end

  context "when initialized with a string: argument" do
    it 'uses that argument as indentation string' do
      dev.indent(string: ">>").print "*"
      expect(res).to eq(">>*")
    end
  end

  context "when initialized with bol == true" do
    it 'indents the next character' do
      for method in [:print, :puts, :p] do
        quote = (method == :p ? '"' : '')
        endl = (method == :p || method == :puts ? "\n" : "")
        quoted_endl = (method == :p ? '\n' : "\n")

        dev.print("Hello")
        dev.indent(bol: true).send(method, "Beautiful")
        expect(res).to eq("Hello  #{quote}Beautiful#{quote}#{endl}")
      end
    end
  end

  context "when initialized with bol == false" do
    it 'indents only after the next newline' do
      for method in [:print, :puts, :p] do
        dev.print("Hello")
        dev.indent(bol: false).send(method, "Beautiful\nWorld")
        case method
        when :p; expect(res).to eq("Hello\"Beautiful\\nWorld\"\n")
        when :puts; expect(res).to eq("HelloBeautiful\n  World\n")
        when :print; expect(res).to eq("HelloBeautiful\n  World")
        end
      end
    end
  end

  describe "#indent" do
    include_examples "indent method", IndentedIO::IndentedIO do 
      let(:dev) { StringIO.new }
      let(:recv) { dev.indent(0, "  ") }
      def result() r = dev.string; dev.string = ""; r end
    end

    it 'keeps track of beginning-of-line status' do
      # Going up the stack
      out = dev.indent
      out.print "Hello"
      out.indent.print "Beautiful"
      expect(res).to eq("  HelloBeautiful")

      # Going down the stack
      out = dev.indent
      out.print "Hello"
      out.indent(-1).print "World"
      expect(res).to eq("  HelloWorld")

      # Going back to previous level
      out = dev.indent
      out.print "Hello"
      out.indent.print "Beautiful\n"
      out.print "World"
      expect(res).to eq("  HelloBeautiful\n  World")
    end
  end

  describe "#write" do
    include_examples "output methods", :write
  end

  describe "#print" do
    include_examples "output methods", :print
  end

  describe "#printf" do
    it 'interpolates its arguments and forwards to #write' do
      dev.indent.printf "%s", "Hello"
      expect(res).to eq("  Hello")
    end
  end

  describe "#puts" do
    include_examples "output methods", :puts
  end

  describe "#p" do
    include_examples "output methods", :p
  end
end
