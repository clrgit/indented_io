require 'support/indent_method'

describe StringIO do
  describe "#indent" do
    include_examples "indent method" do
      let(:dev) { StringIO.new }
      let(:recv) { dev }
      def result() r = dev.string; dev.string = ""; r end
    end
  end
end

