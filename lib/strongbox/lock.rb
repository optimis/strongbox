module Strongbox
  # The Lock class encrypts and decrypts the protected attribute.  It 
  # automatically encrypts the data when set and decrypts it when the private
  # key password is provided.
  class Lock
      
    def initialize options = {}
      @size = nil

      options = Strongbox.options.merge(options)
      options = options.with_indifferent_access
      
      @name             = options[:name]
      @instance         = options[:instance]
      @base64           = options[:base64]
      @public_key       = options[:public_key] || options[:key_pair]
      @private_key      = options[:private_key] || options[:key_pair]
      @padding          = options[:padding]
      @symmetric_cipher = options[:symmetric_cipher]
      @symmetric_key    = options[:symmetric_key] || "#{@name}_key"
      @symmetric_iv     = options[:symmetric_iv] || "#{@name}_iv"

      @api_key = options[:api_key]
      @decryption_service_url = options[:decryption_service_url]
      @password = options[:password]
    end
    
    def encrypt plaintext
      return if plaintext.blank?

      @size = plaintext.size # For validations
      # Using a blank password in OpenSSL::PKey::RSA.new prevents reading
      # the private key if the file is a key pair

      ciphertext, random_key, random_iv = symetric_encryption(plaintext)

      encrypted_key = asymetric_encryption(random_key)
      encrypted_iv  = asymetric_encryption(random_iv)

      if @base64
        ciphertext    = Base64.encode64(ciphertext) 
        encrypted_key = Base64.encode64(encrypted_key) 
        encrypted_iv  = Base64.encode64(encrypted_iv) 
      end

      if @instance.kind_of?(ActiveRecord::Base)
        store_encrypted_data(ciphertext, encrypted_key, encrypted_iv) 
      end

      [ciphertext, encrypted_key, encrypted_iv]
    end

    def store_encrypted_data(ciphertext, encrypted_key, encrypted_iv)
      @instance[@name] = ciphertext
      @instance[@symmetric_key] = encrypted_key
      @instance[@symmetric_iv] = encrypted_iv
    end

    def symetric_encryption plaintext
      cipher = OpenSSL::Cipher::Cipher.new(@symmetric_cipher)
      cipher.encrypt
      cipher.key = random_key = cipher.random_key
      cipher.iv = random_iv = cipher.random_iv

      ciphertext = cipher.update(plaintext)
      ciphertext << cipher.final


      [ciphertext, random_key, random_iv]
    end

    def asymetric_encryption plaintext
      unless @public_key
        raise StrongboxError.new("No public key_file")
      end
      public_key = get_rsa_key(@public_key, "")

      public_key.public_encrypt(plaintext, @padding)
    end

    def decrypt
      if @decryption_service_url
        decrypt_remotely
      else
        decrypt_locally
      end
    end
   

    def decrypt_remotely
      RestClient.post(@decryption_service_url, remote_params)
    end

    # Given the private key password decrypts the attribute.  Will raise
    # OpenSSL::PKey::RSAError if the password is wrong.
    
    def decrypt_locally
      # Given a private key and a nil password OpenSSL::PKey::RSA.new() will
      # *prompt* for a password, we default to an empty string to avoid that.
      ciphertext = @instance[@name]
      return nil if ciphertext.nil?
      return "" if ciphertext.empty?
      
      return "*encrypted*" if @password.nil?
      unless @private_key
        raise StrongboxError.new("#{@instance.class} model does not have private key_file")
      end
      
      if ciphertext
        ciphertext = Base64.decode64(ciphertext) if @base64
        private_key = get_rsa_key(@private_key, @password)
        random_key = @instance[@symmetric_key]
        random_iv  = @instance[@symmetric_iv]
        if @base64
          random_key = Base64.decode64(random_key)
          random_iv  = Base64.decode64(random_iv)
        end
        cipher = OpenSSL::Cipher::Cipher.new(@symmetric_cipher)
        cipher.decrypt
        cipher.key = private_key.private_decrypt(random_key, @padding)
        cipher.iv  = private_key.private_decrypt(random_iv, @padding)
        plaintext  = cipher.update(ciphertext)
        plaintext  << cipher.final
      else
        nil
      end
    end
    
    def to_s
      decrypt
    end
    
    # Needed for validations
    def blank?
      @instance[@name].blank?
    end
    
    def nil?
      @instance[@name].nil?
    end
    
    def size
      @size
    end

private
     def sign!(params_hash = {})
      digest = Digest::SHA2.new
      params_hash.keys.sort.each do |key|
        digest.update(key)
        data = params_hash[key]
        digest.update(data)
      end
      digest.update(@api_key)
      
      params_hash[:signature] = digest.to_s
    end

    def remote_params
      p = {
        "encrypted_data" => @instance[@name],
        "encrypted_key"  => @instance[@symmetric_key],
        "encrypted_iv"   => @instance[@symmetric_iv]
      }
      sign!(p)
      p
    end

    def get_rsa_key(key, password = '')
      return key if key.is_a?(OpenSSL::PKey::RSA)
      if key !~ /^-+BEGIN .* KEY-+$/
        key = File.read(key)
      end
      return OpenSSL::PKey::RSA.new(key, password)
    end

  end # class Lock
end # module StrongBox
