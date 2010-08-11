require 'test/test_helper'

class PaperclipProcessorTest < Test::Unit::TestCase
  context "uploaded file data" do
    setup do
      @password = 'boost facile'
      @file = File.open(File.join(FIXTURES_DIR, 'example.pdf'))
      @expected_encrypted_file = File.open(File.join(FIXTURES_DIR, 'example.pdf.encrypted'))
      @options = {
        :key_pair => File.join(FIXTURES_DIR,'keypair.pem'),
        :base64   => true
      }
    end
    
    should 'encrypt' do
      pr = Strongbox::PaperclipProcessor.new @file, @options

      assert_match BASE64_REGEX, pr.make.read
    end
  end
end
