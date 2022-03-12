describe IndentedIO::IndentedIOInterface do
  context "the interface" do
    it "is included in the IO class" do
      expect(IO.included_modules).to include IndentedIO::IndentedIOInterface
    end
    it "is included in the StringIO class" do
      expect(StringIO.included_modules).to include IndentedIO::IndentedIOInterface
    end
    it "is included in the IndentedIO class" do
      expect(IndentedIO::IndentedIO.included_modules).to include IndentedIO::IndentedIOInterface
    end
  end
  describe "#indent" do
    it "writes indented text"
  end
  describe "#depth" do
    it "returns the current indentation depth" do
      expect($stderr.indent.depth).to eq 1
      expect($stderr.indent.indent.depth).to eq 2
    end
    it "returns 0 for unindented devices" do
      expect($stderr.depth).to eq 0
    end
  end
  describe "#tab" do
    it "returns the current tab position" do
      dev = $stderr
      expect(dev.tab).to eq 0
      dev = dev.indent(1, " ")
      expect(dev.tab).to eq 1
      dev = dev.indent(2, "  ")
      expect(dev.tab).to eq 5
    end
    it "returns 0 for unindented devices" do
      expect($stderr.tab).to eq 0
    end
  end
end
