
include IndentedIO

describe IndentedIO do
  it 'has a version number' do
    expect(::IndentedIO::VERSION).not_to be_nil
  end

  describe '.default_indent' do
    it 'returns the default indentation string' do
      expect(IndentedIO.default_indent).to eq("  ")
    end
  end

  describe '.default_indent=' do
    it 'sets the default indentation string' do
      saved_default_indent = IndentedIO.default_indent
      begin
        IndentedIO.default_indent = "--"
        expect(IndentedIO.default_indent).to eq("--")
      ensure
        IndentedIO.default_indent = saved_default_indent
      end
    end
  end
end
