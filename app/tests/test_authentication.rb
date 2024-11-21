require 'minitest/autorun'
require 'jwt'
require_relative '../authentication'
require_relative '../user'
require_relative '../security'

class TestAuthentication < Minitest::Test
  def setup
    @username = "test_user"
    @password = "password123"
    @user_id = 1
    @hmac_secret = 'fudoapp'

    @user_mock = Minitest::Mock.new
    User.stub(:find_user_by_username, @user_mock) do
      @user_mock.expect(:call, { id: @user_id, password: Security.encripted_password(@password) }, [@username])
    end
  end

  def test_decode_token
    payload = { "user_id" => @user_id }
    token = JWT.encode(payload, @hmac_secret, 'HS256')

    decoded = Authentication.decode_token(token)
    assert_equal payload["user_id"], decoded["user_id"], "La decodificación debería devolver el mismo user_id"
  end

  def test_decode_token_invalid
    invalid_token = "token_invalido"

    decoded = Authentication.decode_token(invalid_token)
    assert_equal decoded, false
  end

  def test_authenticate_failure
    token = "token_invalido"
    assert_equal false, Authentication.authenticate!(token), "La autenticación debería fallar con un token inválido"
  end

  def test_user_valid
    User.stub(:find_user_by_username, { id: @user_id }) do
      assert Authentication.user_valid?(@username), "El usuario debería ser válido"
    end
  end

  def test_user_invalid
    User.stub(:find_user_by_username, nil) do
      refute Authentication.user_valid?("invalid_user"), "El usuario debería ser inválido"
    end
  end

  def test_password_invalid
    Security.stub(:decrypt_password, "wrong_password") do
      refute Authentication.password_valid?(@username, "invalid_password"), "La contraseña debería ser inválida"
    end
  end
end
