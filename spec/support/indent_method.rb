# Environment
#   :recv - the object that will receive the #indent call
#   result() - a method returning the resulting output as a string. #result
#              should reset the result to the empty string
#
# Parameters
#   klass - the class of the tested object. Only relevant if klass == Kernel
#           or IndentedIO::IndentedIO
#
# Example use
#   include_examples "indent method" do
#     let(:dev) { StringIO.new }
#     let(:recv) { IndentedIO::IndentedIO.new(dev, 0, "  ", true) }
#     def result() r = dev.string; dev.string = ""; r end
#   end
#
shared_examples "indent method" do |klass=nil|
  if klass == Kernel
    it 'can take a block with zero or one parameters' do
      expect { recv.indent {} }.not_to raise_error
      expect { recv.indent { |_| } }.not_to raise_error
      expect { recv.indent { |_,_| } }.to raise_error(IndentedIO::Error)
    end
  elsif
    it 'can take a block with one parameter' do
      expect { recv.indent {} }.to raise_error(IndentedIO::Error)
      expect { recv.indent { |_| } }.not_to raise_error
      expect { recv.indent { |_,_| } }.to raise_error(IndentedIO::Error)
    end
  end

  it 'pass arguments to IndentedIO.new' do
    recv.indent(1) { |io| io.puts "*" }
    expect(result).to eq(IndentedIO.default_indent + "*\n")

    recv.indent(2) { |io| io.puts "*" }
    expect(result).to eq(IndentedIO.default_indent * 2 + "*\n")

    recv.indent(2, ">") { |io| io.puts "*" }
    expect(result).to eq(">>*\n")

    recv.indent(2, string: ">") { |io| io.puts "*" }
    expect(result).to eq(">>*\n")

    recv.indent(bol: true) { |io| io.puts "a\nb" }
    expect(result).to eq("  a\n  b\n")
  end

  if klass == IndentedIO::IndentedIO
    it 'uses own indent as default' do
      recv.indent(1, ">>").indent.print "*"
      expect(result).to eq(">>>>*")
    end
  else
    it 'uses IndentedIO.default_indent as default' do
      recv.indent(1).print "*"
      expect(result).to eq(IndentedIO.default_indent + "*")
    end
  end

  context "when called with a block" do
    it 'calls the block with the IndentedIO argument' do
      expect(recv.indent { |arg| arg.class }).to eq(IndentedIO::IndentedIO)
    end

    it 'returns the value of the block' do
      expect(recv.indent { |_| 42 }).to eq(42)
      expect(recv.indent { 42 }).to eq(42) if klass == Kernel
    end
  end

  context "when called without a block" do
    it 'returns the IndentedIO object' do
      expect(recv.indent.class).to eq(IndentedIO::IndentedIO)
    end
  end
end

