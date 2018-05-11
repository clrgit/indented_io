require 'support/indent_method'

require 'tempfile'

TMPFILE = Tempfile.new

describe IO do
  describe "#indent" do
    include_examples "indent method" do
      let(:recv) { TMPFILE }
      def result()
        TMPFILE.flush
        TMPFILE.rewind
        r = TMPFILE.read
        TMPFILE.rewind
        TMPFILE.truncate(0)
        r
      end
    end
  end
end

