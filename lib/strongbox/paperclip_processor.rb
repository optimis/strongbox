require 'paperclip'
module Strongbox
  class PaperclipProcessor < ::Paperclip::Processor
    attr_reader :instance

    def initialize file, options = {}
      super
      @name = options[:name]
      @file = file
      @instance = attachment.try(:instance)
      @lock = Strongbox::Lock.new(options)
    end

    def make
      @file.rewind
      data, key, iv = @lock.encrypt(@file.read)
      temp = Tempfile.new(Time.now.usec)
      temp.write(data)
      if !@name.nil?
        instance["#{@name}_key"] = key
        instance["#{@name}_iv"] = iv
      end
      @file.unlink if @file.kind_of?(Tempfile)

      temp.rewind
      temp
    end
  end
end
