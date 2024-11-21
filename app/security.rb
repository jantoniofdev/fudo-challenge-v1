class Security
  def self.encripted_password(data)
    cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    cipher.encrypt
    @key = cipher.random_key
    @iv = cipher.random_iv
    (cipher.update(data) + cipher.final)
  end

  def self.decrypt_password(encrypted)
    decipher = OpenSSL::Cipher::AES.new(128, :CBC)
    decipher.decrypt
    decipher.key = @key
    decipher.iv = @iv

    (decipher.update(encrypted) + decipher.final)
  end
end