require 'minitest/autorun'
require 'openssl'
require './security'

class TestSecurity < Minitest::Test
  def setup
    @data = "SuperSecretPassword123"
  end

  def test_encripted_password
    encrypted = Security.encripted_password(@data)
    assert_instance_of String, encrypted, "El resultado del cifrado debe ser un String"
    refute_equal @data, encrypted, "El texto cifrado no debe ser igual al original"
  end

  def test_decrypt_password
    encrypted = Security.encripted_password(@data)
    decrypted = Security.decrypt_password(encrypted)
    assert_equal @data, decrypted, "El texto descifrado debe coincidir con el original"
  end
end
