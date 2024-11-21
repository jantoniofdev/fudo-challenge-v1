require './security'
require './user'

class Authentication
  HMAC_SECRET = 'fudoapp'

  def self.generate_token(username)
    user = User.find_user_by_username(username)
    return false unless user
    payload = { user_id: user.id }
    hmac_secret = HMAC_SECRET
    JWT.encode(payload, hmac_secret, 'HS256')
    rescue JWT::EncodeError
      false
  end

  def self.decode_token(token)
    hmac_secret = HMAC_SECRET
    JWT.decode(token, hmac_secret, true, algorithm: 'HS256').first
    rescue JWT::DecodeError
      false
  end

  def self.authenticate!(token)
    return false unless token
    payload = Authentication.decode_token(token)
    return false if payload == false
    user = User.find_user_by_id(payload['user_id'])
    return false unless user
    
    user.id == payload['user_id']
  end

  def self.user_valid?(username)
    !!User.find_user_by_username(username)
  end

  def self.password_valid?(username, password)
    user = User.find_user_by_username(username)
    return false unless user

    decrypted = Security.decrypt_password(user.password)
    decrypted == password
  rescue StandardError
    false
  end
end