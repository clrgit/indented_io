require 'support/indent_method'

require 'string-text'
using String::Text

describe Kernel do
  describe '#indent' do
    include_examples "indent method", Kernel do
      let(:dev) { StringIO.new }
      let(:recv) { Kernel }
      let!(:stored_stdout) { $stdout }
      before(:each) { $stdout = dev }
      after(:each) { $stdout = stored_stdout }
      def result() r = dev.string; dev.string = ""; r end
    end

    context 'with one block parameter' do
      it 'doesn\'t change the global $stdout object' do
        saved_stdout = $stdout
        indent { |io| expect($stdout).to eq(saved_stdout) }
      end
      it 'calls the block with an IndentedIO object' do
        indent(0) { |io| expect(io).to be_a(IndentedIO::IndentedIO) }
      end
    end

    context 'with no block parameter' do
      it 'changes $stdout to a IndentedIO object' do
        saved_stdout = $stdout
        indent(0) { expect($stdout).to be_a(IndentedIO::IndentedIO) }
      end
      it 'changes $stdout back after the block terminates' do
        saved_stdout = $stdout
        indent(0) { ; }
        expect($stdout).to eq(saved_stdout)
      end
      it 'changes $stdout back if an exception is raised' do
        saved_stdout = $stdout
        indent(0) { raise "Error" } rescue RuntimeError
        expect($stdout).to eq(saved_stdout)
      end
    end

    context "with no block" do
      it 'changes $stdout to a IndentedIO object' do
        saved_stdout = $stdout
        indent
        expect($stdout).to be_a(IndentedIO::IndentedIO)
      end
      it "indents globally" do
        expect { indent; puts "line" }.to output("  line\n").to_stdout
      end
    end
  end

  describe "#undent" do
    it "cancels indentation" do
      indent
      undent
      expect { puts "line" }.to output("line\n").to_stdout
    end

    it "can be mixed with block indents" do
      expected = %(
        0
          2
            4
              6
              6
          2
        0
      ).align + "\n"

      expect {
        puts "0"
        indent
        puts "2"
        indent {
          puts "4"
          indent
          puts "6"
          undent
          indent {
            puts "6"
          }
        }
        puts 2
        undent
        puts "0"
      }.to output(expected).to_stdout
    end
  end
end







