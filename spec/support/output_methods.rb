shared_examples "output methods" do |method| # method is :write, :print, :puts, or :p
  # Generalize output format
  quote = (method == :p ? '"' : '')
  endl = (method == :write || method == :print ? "" : "\n")

  let(:device) { StringIO.new }
  let(:output) { device.indent }
  def result() r = device.string; device.string = ""; r end

  it 'prints indented' do
    device.indent(1, " ").send method, "Hello"
    expect(result).to eq(" #{quote}Hello#{quote}#{endl}")

    device.indent(2, "-").send method, "Hello"
    expect(result).to eq("--#{quote}Hello#{quote}#{endl}")
  end

  if method != :p
    context 'when writing empty lines' do
      it 'doesn\'t output the indentation' do
        output.send(method, "\n\n")
        expect(result).to eq("\n\n#{endl}")
      end
    end

    context 'when called with an empty string' do
      if method == :puts
        it 'outputs an empty line' do
          output.send(method, "")
          expect(result).to eq("\n")
        end
      else
        it 'does nothing' do
          output.send(method, "")
          expect(result).to eq("")
        end
      end
    end
  end

  context "when called with no arguments" do
    if method == :puts
      it 'outputs an empty line' do
        output.puts 'Hello'
        output.puts
        output.puts 'World'
        expect(result).to eq("  Hello\n\n  World\n")
      end
    else
      it 'doesn\'t output anything' do
        output.send(method)
        expect(result).to eq('')
      end
    end
  end

  if method == :p
    context "when called with one argument" do
      it "returns that argument" do
        obj = "Object"
        expect(output.p(obj)).to eq(obj)
      end
    end
    context "when called with more than one argument" do
      it 'returns an array of the arguments' do
        obj1 = "Object 1"
        obj2 = "Object 2"
        expect(output.p(obj1, obj2)).to eq([obj1, obj2])
      end
    end
  elsif method == :write
    it 'returns the number of bytes written' do
      n = output.write('Hello')
      expect(n).to eq(7)
    end
  else
    it 'returns nil' do
      expect(output.send method, "Hello\n").to eq(nil)
    end
  end
end
