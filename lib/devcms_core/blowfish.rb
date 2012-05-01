module DevcmsCore
  # Encrypts and decrypts text using openSSL
  class Blowfish
    require 'openssl'

    # Encrypts some text using a given key. The encrypted text is returned as base64 encoded text
    def self.encrypt(key, plaintext)
      cipher = new_cipher
      cipher.encrypt
      cipher.key = key
      ciphertext = cipher.update plaintext
      ActiveSupport::Base64.encode64(ciphertext << cipher.final).gsub(/\n/, '')
    end

    # Decrypts base64 encoded encypted text and returns the result
    # A 'OpenSSL::CipherError: bad decrypt' error is thrown when decryption failed using the given key.
    def self.decrypt(key, encrypted_text)
      encrypted_text = ActiveSupport::Base64.decode64(encrypted_text)
      cipher = new_cipher
      cipher.decrypt
      cipher.key = key
      plaintext = cipher.update encrypted_text
      plaintext << cipher.final
    end

  private

    def self.new_cipher
      OpenSSL::Cipher::Cipher.new "bf"
    end
  end
end
