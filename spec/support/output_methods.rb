shared_examples "output methods" do |method| # method is :p, :puts, or :print
  # Generalize output format
  quote = (method == :p ? '"' : '')
  endl = (method == :print ? "" : "\n")

  it 'prints indented' do
    dev = StringIO.new
    dev.indent(1, " ").send method, "Hello"
    expect(dev.string).to eq(" #{quote}Hello#{quote}#{endl}")

    dev = StringIO.new
    dev.indent(2, "-").send method, "Hello"
    expect(dev.string).to eq("--#{quote}Hello#{quote}#{endl}")
  end

  context 'when called with an empty string' do
    it "outputs the indendation#{method == :print ? "" : " followed by a newline"}" do
      dev = StringIO.new
      dev.indent(1, " ").send method, ""
      expect(dev.string).to eq(" #{quote}#{quote}#{endl}")
    end
  end

  if method == :p
    context "when called with one argument" do
      it "returns that argument" do
        obj = "Object"
        expect(out.p(obj)).to eq(obj)
      end
    end
    context "when called with more than one argument" do
      it 'returns an array of the arguments' do
        obj1 = "Object 1"
        obj2 = "Object 2"
        expect(out.p(obj1, obj2)).to eq([obj1, obj2])
      end
    end
  else
    it 'returns nil' do
      expect(out.send method, "Hello\n").to eq(nil)
    end
  end
end

